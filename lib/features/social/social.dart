import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/cloud_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../challenges/challenges.dart';
import '../workouts/data/workout_repository.dart';

// =============================================================================
// Shareable image cards
// =============================================================================

class ShareStat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const ShareStat(this.icon, this.value, this.label, this.color);
}

/// Shows a preview of a branded card and shares it as a PNG.
Future<void> showShareCard(
  BuildContext context, {
  required String title,
  required String subtitle,
  required List<ShareStat> stats,
  String? badge,
}) =>
    showDialog(
      context: context,
      builder: (_) => _ShareDialog(title: title, subtitle: subtitle, stats: stats, badge: badge),
    );

class _ShareDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<ShareStat> stats;
  final String? badge;
  const _ShareDialog({required this.title, required this.subtitle, required this.stats, this.badge});

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  final _key = GlobalKey();
  bool _busy = false;

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final boundary = _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/fit_companion_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(data!.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'image/png')], text: '#FitCompanion'));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.coachErrGeneric)));
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _key,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: context.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: primary.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/branding/logo.png', width: 36, height: 36, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Text('Fit Companion', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const Spacer(),
                      if (widget.badge != null) Pill(label: widget.badge!, color: primary),
                    ]),
                    const SizedBox(height: 22),
                    Text(widget.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(widget.subtitle, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final s in widget.stats)
                          Container(
                            width: 128,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(s.icon, color: s.color, size: 22),
                                const SizedBox(height: 6),
                                Text(s.value,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                                Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel))),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(l10n.shareAction),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Friends & leaderboard (Supabase, free plan; only friends can read your stats)
// =============================================================================

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _me;
  List<Map<String, dynamic>> _rows = [];
  String _sort = 'week_volume_kg';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final cloud = ref.read(cloudServiceProvider);
    if (cloud.user == null) {
      setState(() {
        _loading = false;
        _error = 'unauthorized';
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final db = ref.read(databaseProvider);
      final profile = await (db.select(db.profiles)..limit(1)).getSingleOrNull();
      final g = await ref.read(challengesRepositoryProvider).compute();
      final history = await WorkoutRepository(db).watchWorkoutHistory().first;
      final stats = WorkoutRepository.computeStats(history, DateTime.now());
      final week = g.challenges.firstWhere((c) => c.def.id == 'w_workouts').value;
      final wStart = weekStart(DateTime.now());
      final weekVolume = history.where((s) => !s.startTime.isBefore(wStart)).fold<double>(0, (a, s) => a + s.totalVolumeKg);
      _me = await cloud.upsertFriendProfile({
        'display_name': (profile?.displayName?.trim().isNotEmpty ?? false) ? profile!.displayName!.trim() : 'Athlete',
        'level': g.level.level,
        'xp': g.level.xp,
        'week_workouts': week.toInt(),
        'week_volume_kg': weekVolume,
        'streak_days': stats.currentStreakDays,
      });
      _rows = await cloud.friendLeaderboard();
      _error = null;
    } catch (e) {
      _error = e is CoachException ? e.code : 'network';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.friendsAdd),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
          decoration: InputDecoration(labelText: l10n.friendsCode),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(l10n.friendsAdd)),
        ],
      ),
    );
    ctrl.dispose();
    if (code == null || code.length < 4) return;
    try {
      final name = await ref.read(cloudServiceProvider).addFriend(code);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.friendsAdded(name))));
      await _refresh();
    } on CoachException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(switch (e.code) {
          'code_not_found' => l10n.friendsCodeNotFound,
          'own_code' => l10n.friendsOwnCode,
          _ => l10n.coachErrGeneric,
        }),
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.coachErrGeneric)));
    }
  }

  Future<void> _remove(Map<String, dynamic> row) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.friendsRemove),
        content: Text(l10n.friendsRemoveConfirm(row['display_name'].toString())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.friendsRemove)),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(cloudServiceProvider).removeFriend(row['user_id'].toString());
    } catch (_) {}
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final myId = _me?['user_id'];
    final sorted = [..._rows]..sort((a, b) => (b[_sort] as num).compareTo(a[_sort] as num));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.friendsTitle)),
      floatingActionButton: _error == null && !_loading
          ? FloatingActionButton.extended(onPressed: _add, icon: const Icon(Icons.person_add_alt_1_rounded), label: Text(l10n.friendsAdd))
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.group_rounded, size: 56),
                      const SizedBox(height: 12),
                      Text(_error == 'unauthorized' ? l10n.friendsNeedAccount : l10n.coachErrGeneric, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _error == 'unauthorized' ? () => context.push('/settings/cloud') : _refresh,
                        child: Text(_error == 'unauthorized' ? l10n.aiSignIn : l10n.friendsRetry),
                      ),
                    ]),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
                    children: [
                      AppCard(
                        gradient: context.heroGradient,
                        child: Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(l10n.friendsMyCode, style: theme.textTheme.labelMedium),
                              Text(_me?['friend_code']?.toString() ?? '—',
                                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 4)),
                              Text(l10n.friendsMyCodeHint, style: theme.textTheme.bodySmall),
                            ]),
                          ),
                          IconButton.filledTonal(
                            tooltip: l10n.friendsCopy,
                            icon: const Icon(Icons.copy_rounded),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _me?['friend_code']?.toString() ?? ''));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.friendsCopied)));
                            },
                          ),
                          IconButton.filledTonal(
                            tooltip: l10n.shareAction,
                            icon: const Icon(Icons.share_rounded),
                            onPressed: () => SharePlus.instance.share(ShareParams(text: l10n.friendsInvite(_me?['friend_code']?.toString() ?? ''))),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 14),
                      SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: 'week_volume_kg', label: Text(l10n.friendsSortVolume)),
                          ButtonSegment(value: 'week_workouts', label: Text(l10n.friendsSortWorkouts)),
                          ButtonSegment(value: 'xp', label: const Text('XP')),
                        ],
                        selected: {_sort},
                        onSelectionChanged: (s) => setState(() => _sort = s.first),
                      ),
                      const SizedBox(height: 10),
                      if (sorted.length <= 1)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(l10n.friendsEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                        ),
                      for (final (i, r) in sorted.indexed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: r['user_id'] == myId ? Border.all(color: theme.colorScheme.primary, width: 1.5) : null,
                            onLongPress: r['user_id'] == myId ? null : () => _remove(r),
                            child: Row(children: [
                              SizedBox(
                                width: 30,
                                child: Text(i < 3 ? ['🥇', '🥈', '🥉'][i] : '${i + 1}',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              ),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(r['user_id'] == myId ? '${r['display_name']} (${l10n.friendsYou})' : r['display_name'].toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                  Text(
                                    '${l10n.friendsLevel(r['level'] as int)} · 🔥 ${r['streak_days']}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ]),
                              ),
                              Text(
                                switch (_sort) {
                                  'week_workouts' => '${r['week_workouts']}',
                                  'xp' => '${r['xp']}',
                                  _ => '${((r['week_volume_kg'] as num) / 1000).toStringAsFixed(1)} t',
                                },
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
                              ),
                            ]),
                          ),
                        ),
                      if (sorted.length > 1)
                        Text(l10n.friendsRemoveHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
    );
  }
}

/// Small entry row used on the challenges screen.
class FriendsEntryTile extends StatelessWidget {
  const FriendsEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      onTap: () => context.push('/friends'),
      child: Row(children: [
        IconBadge(icon: Icons.groups_rounded, color: AppColors.cyan, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.friendsTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            Text(l10n.friendsSubtitle, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded),
      ]),
    );
  }
}
