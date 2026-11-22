import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/cloud_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../coach/coach_context.dart';

final progressPhotosProvider = StreamProvider<List<ProgressPhoto>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.progressPhotos)..orderBy([(t) => OrderingTerm.desc(t.timestamp)])).watch();
});

String poseLabel(AppLocalizations l10n, String pose) => switch (pose) {
      'side' => l10n.photosSide,
      'back' => l10n.photosBack,
      _ => l10n.photosFront,
    };

/// Adds a progress photo: pick the date (today, last week…), the pose and the source.
Future<void> addProgressPhoto(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  DateTime date = DateUtils.dateOnly(DateTime.now());
  String pose = 'front';
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.photosAdd, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(l10n.photosDate, style: Theme.of(ctx).textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final d in [0, 7, 14, 30])
                    ChoiceChip(
                      label: Text(switch (d) {
                        0 => l10n.commonToday,
                        7 => l10n.photosLastWeek,
                        14 => l10n.photos2Weeks,
                        _ => l10n.photosLastMonth,
                      }),
                      selected: DateUtils.isSameDay(date, DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: d))),
                      onSelected: (_) => setState(() => date = DateUtils.dateOnly(DateTime.now()).subtract(Duration(days: d))),
                    ),
                  ActionChip(
                    avatar: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(DateFormat.yMMMd(Localizations.localeOf(ctx).languageCode).format(date)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => date = DateUtils.dateOnly(picked));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.photosPose, style: Theme.of(ctx).textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  for (final ps in ['front', 'side', 'back'])
                    ChoiceChip(label: Text(poseLabel(l10n, ps)), selected: pose == ps, onSelected: (_) => setState(() => pose = ps)),
                ],
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(l10n.photosCamera),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.photosGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  if (source == null) return;
  final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
  if (picked == null) return;
  final db = ref.read(databaseProvider);
  final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'progress_photos'));
  await dir.create(recursive: true);
  final id = const Uuid().v4();
  final dest = p.join(dir.path, '$id${p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path)}');
  await File(picked.path).copy(dest);
  // Weight closest to the chosen date
  final metrics = await (db.select(db.bodyMetrics)..orderBy([(m) => OrderingTerm.asc(m.timestamp)])).get();
  double? weight;
  if (metrics.isNotEmpty) {
    metrics.sort((a, b) => (a.timestamp.difference(date).abs()).compareTo(b.timestamp.difference(date).abs()));
    if (metrics.first.timestamp.difference(date).inDays.abs() <= 7) weight = metrics.first.weightKg;
  }
  final ts = DateTime(date.year, date.month, date.day, 12);
  await db.into(db.progressPhotos).insert(ProgressPhotosCompanion.insert(
        id: id,
        date: "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        timestamp: ts,
        filePath: dest,
        pose: Value(pose),
        weightKg: Value(weight),
      ));
  HapticFeedback.mediumImpact();
}

/// Private progress photos + before/after comparison + AI progress analysis.
class ProgressPhotosScreen extends ConsumerStatefulWidget {
  const ProgressPhotosScreen({super.key});

  @override
  ConsumerState<ProgressPhotosScreen> createState() => _ProgressPhotosScreenState();
}

class _ProgressPhotosScreenState extends ConsumerState<ProgressPhotosScreen> {
  String _pose = 'front';
  String? _beforeId;
  String? _afterId;
  bool _analyzing = false;

  Future<void> _delete(ProgressPhoto photo) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.progressPhotos)..where((t) => t.id.equals(photo.id))).go();
    try {
      await File(photo.filePath).delete();
    } catch (_) {}
  }

  Future<void> _analyze(ProgressPhoto before, ProgressPhoto after) async {
    final l10n = AppLocalizations.of(context)!;
    final cloud = ref.read(cloudServiceProvider);
    if (cloud.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.myFoodNeedAccount)));
      context.push('/settings/cloud');
      return;
    }
    // Explicit consent: these photos leave the phone only for this analysis.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.privacy_tip_rounded, size: 34),
        title: Text(l10n.photosAiConsentTitle),
        content: Text(l10n.photosAiConsent),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.photosAiAnalyze)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _analyzing = true);
    try {
      final locale = ref.read(localeProvider).languageCode;
      String label(String tag, ProgressPhoto ph) =>
          '$tag – ${ph.date} – ${ph.pose}${ph.weightKg != null ? ' – ${ph.weightKg!.toStringAsFixed(1)} kg' : ''}';
      final ctx = await CoachContextBuilder(ref.read(databaseProvider)).build();
      final days = after.timestamp.difference(before.timestamp).inDays;
      final r = await cloud.analyzeImages(
        mode: 'progress',
        language: locale,
        images: [
          VisionImage(await File(before.filePath).readAsBytes(), label: label('BEFORE', before)),
          VisionImage(await File(after.filePath).readAsBytes(), label: label('AFTER', after)),
        ],
        extra: {'photo_info': '${label('BEFORE', before)}; ${label('AFTER', after)}; $days days apart', 'context': ctx},
      );
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => _AnalysisSheet(result: r, days: days),
      );
    } on CoachException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(switch (e.code) {
            'daily_limit' => l10n.coachErrLimit,
            'missing_gemini_key' || 'gemini_key' => l10n.coachErrNoKey,
            'gemini_busy' || 'gemini_quota' => l10n.coachErrBusy,
            _ => l10n.coachErrGeneric,
          }),
        ));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.coachErrNetwork)));
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final photos = ref.watch(progressPhotosProvider).value ?? const <ProgressPhoto>[];
    final ofPose = photos.where((ph) => ph.pose == _pose).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    ProgressPhoto? find(String? id) => ofPose.where((ph) => ph.id == id).firstOrNull;
    final before = find(_beforeId) ?? (ofPose.length >= 2 ? ofPose.first : null);
    final after = find(_afterId) ?? (ofPose.length >= 2 ? ofPose.last : null);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.photosTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => addProgressPhoto(context, ref),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: Text(l10n.photosAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 100),
        children: [
          Text(l10n.photosPrivacy, style: theme.textTheme.bodySmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: [
              for (final ps in ['front', 'side', 'back'])
                ChoiceChip(
                  label: Text('${poseLabel(l10n, ps)} (${photos.where((x) => x.pose == ps).length})'),
                  selected: _pose == ps,
                  onSelected: (_) => setState(() {
                    _pose = ps;
                    _beforeId = null;
                    _afterId = null;
                  }),
                ),
            ],
          ),
          if (before != null && after != null && before.id != after.id) ...[
            SectionHeader(title: l10n.photosCompare, padding: const EdgeInsets.only(top: 14, bottom: 8)),
            _Compare(before: before, after: after, locale: locale),
            const SizedBox(height: 10),
            // Pick which two photos to compare
            Row(
              children: [
                Expanded(child: _PhotoPicker(label: l10n.photosBefore, photos: ofPose, selected: before, locale: locale, onPick: (ph) => setState(() => _beforeId = ph.id))),
                const SizedBox(width: 8),
                Expanded(child: _PhotoPicker(label: l10n.photosAfter, photos: ofPose, selected: after, locale: locale, onPick: (ph) => setState(() => _afterId = ph.id))),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.violet, foregroundColor: AppColors.onSecondary),
                icon: _analyzing
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: AppColors.onSecondary))
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_analyzing ? l10n.photoAnalyzing : l10n.photosAiAnalyze),
                onPressed: _analyzing ? null : () => _analyze(before, after),
              ),
            ),
          ] else if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            AppCard(child: Text(l10n.photosNeedTwo, style: theme.textTheme.bodySmall)),
          ],
          const SizedBox(height: 14),
          if (photos.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Icon(Icons.photo_camera_back_rounded, size: 44, color: AppColors.violet),
                  const SizedBox(height: 10),
                  Text(l10n.photosEmpty, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                ],
              ),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
              children: [
                for (final ph in photos)
                  GestureDetector(
                    onTap: () => _open(ph, locale),
                    onLongPress: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.photosDelete),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
                            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonDelete)),
                          ],
                        ),
                      );
                      if (ok == true) _delete(ph);
                    },
                    child: PhotoThumb(photo: ph, label: '${DateFormat.MMMd(locale).format(ph.timestamp)} • ${poseLabel(l10n, ph.pose)}'),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _open(ProgressPhoto ph, String locale) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(DateFormat.yMMMd(locale).format(ph.timestamp)),
        ),
        body: Center(child: InteractiveViewer(child: Image.file(File(ph.filePath)))),
      ),
    ));
  }
}

class _PhotoPicker extends StatelessWidget {
  final String label;
  final List<ProgressPhoto> photos;
  final ProgressPhoto selected;
  final String locale;
  final ValueChanged<ProgressPhoto> onPick;

  const _PhotoPicker({required this.label, required this.photos, required this.selected, required this.locale, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      onTap: () async {
        final ph = await showModalBottomSheet<ProgressPhoto>(
          context: context,
          builder: (ctx) => SafeArea(
            child: SizedBox(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                children: [
                  for (final x in photos)
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx, x),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: SizedBox(width: 140, child: PhotoThumb(photo: x, label: DateFormat.yMMMd(locale).format(x.timestamp))),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        if (ph != null) onPick(ph);
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(DateFormat.yMMMd(locale).format(selected.timestamp),
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          const Icon(Icons.swap_horiz_rounded, size: 18),
        ],
      ),
    );
  }
}

class PhotoThumb extends StatelessWidget {
  final ProgressPhoto photo;
  final String label;
  const PhotoThumb({super.key, required this.photo, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.filePath),
            fit: BoxFit.cover,
            cacheWidth: 400,
            errorBuilder: (_, __, ___) => Container(color: context.cardHigh, child: const Icon(Icons.broken_image_rounded)),
          ),
          Positioned(left: 6, right: 6, bottom: 6, child: Align(alignment: AlignmentDirectional.centerStart, child: Pill(label: label, color: Colors.white, solid: true))),
        ],
      ),
    );
  }
}

/// Side-by-side before / after with a draggable divider.
class _Compare extends StatefulWidget {
  final ProgressPhoto before;
  final ProgressPhoto after;
  final String locale;
  const _Compare({required this.before, required this.after, required this.locale});

  @override
  State<_Compare> createState() => _CompareState();
}

class _CompareState extends State<_Compare> {
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String caption(ProgressPhoto p) =>
        '${DateFormat.yMMMd(widget.locale).format(p.timestamp)}${p.weightKg != null ? ' • ${p.weightKg!.toStringAsFixed(1)} ${l10n.commonKg}' : ''}';
    final days = widget.after.timestamp.difference(widget.before.timestamp).inDays;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.radiusLg),
            child: LayoutBuilder(
              builder: (context, c) => GestureDetector(
                onHorizontalDragUpdate: (d) => setState(() => _split = (_split + d.delta.dx / c.maxWidth).clamp(0.05, 0.95)),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(File(widget.after.filePath), fit: BoxFit.cover, errorBuilder: _broken),
                      ClipRect(clipper: _LeftClipper(_split), child: Image.file(File(widget.before.filePath), fit: BoxFit.cover, errorBuilder: _broken)),
                      Positioned(left: c.maxWidth * _split - 1.5, top: 0, bottom: 0, child: Container(width: 3, color: AppColors.lime)),
                      Positioned(left: 8, top: 8, child: Pill(label: '${l10n.photosBefore} • ${caption(widget.before)}', color: Colors.white, solid: true)),
                      Positioned(right: 8, bottom: 8, child: Pill(label: '${l10n.photosAfter} • ${caption(widget.after)}', color: AppColors.lime, solid: true)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(l10n.photosDaysApart(days), style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

Widget _broken(BuildContext context, Object _, StackTrace? __) =>
    Container(color: context.cardHigh, alignment: Alignment.center, child: const Icon(Icons.broken_image_rounded));

class _LeftClipper extends CustomClipper<Rect> {
  final double split;
  _LeftClipper(this.split);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * split, size.height);

  @override
  bool shouldReclip(covariant _LeftClipper old) => old.split != split;
}

/// AI progress report.
class _AnalysisSheet extends StatelessWidget {
  final Map<String, dynamic> result;
  final int days;
  const _AnalysisSheet({required this.result, required this.days});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final score = (result['progress_score'] as num?)?.toDouble() ?? 5;
    final comparable = result['comparable'] != false;
    final areas = (result['areas'] as List? ?? const []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final tips = (result['tips'] as List? ?? const []).map((e) => e.toString()).toList();
    String gain(String? v) => switch (v) {
          'clear' => l10n.aiGainClear,
          'slight' => l10n.aiGainSlight,
          'none' => l10n.aiGainNone,
          _ => l10n.aiUnclear,
        };
    String fat(String? v) => switch (v) {
          'less' => l10n.aiFatLess,
          'same' => l10n.aiFatSame,
          'more' => l10n.aiFatMore,
          _ => l10n.aiUnclear,
        };
    Color changeColor(String? c) => switch (c) {
          'improved' => AppColors.success,
          'declined' => AppColors.flame,
          'same' => AppColors.carbs,
          _ => context.textSecondary,
        };

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(l10n.aiProgressTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            gradient: context.heroGradient,
            child: Row(
              children: [
                ProgressRing(
                  progress: score / 10,
                  size: 76,
                  strokeWidth: 8,
                  color: theme.colorScheme.primary,
                  child: Text(score.toStringAsFixed(1), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.aiMuscle}: ${gain(result['muscle_gain'] as String?)}', style: theme.textTheme.titleSmall),
                      Text('${l10n.aiFat}: ${fat(result['fat_change'] as String?)}', style: theme.textTheme.titleSmall),
                      Text(l10n.photosDaysApart(days), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (!comparable)
            AppCard(
              backgroundColor: AppColors.warning.withValues(alpha: 0.15),
              child: Text('${l10n.aiNotComparable}\n${result['photo_tips'] ?? ''}', style: theme.textTheme.bodySmall),
            ),
          const SizedBox(height: 8),
          Text((result['summary'] ?? '').toString(), style: theme.textTheme.bodyMedium?.copyWith(height: 1.5)),
          if (areas.isNotEmpty) ...[
            SectionHeader(title: l10n.aiAreas),
            for (final a in areas)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(margin: const EdgeInsets.only(top: 5), width: 10, height: 10, decoration: BoxDecoration(color: changeColor(a['change'] as String?), shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(text: '${a['area']}: ', style: const TextStyle(fontWeight: FontWeight.w800)),
                        TextSpan(text: (a['note'] ?? '').toString()),
                      ]), style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
          if (tips.isNotEmpty) ...[
            SectionHeader(title: l10n.aiTips),
            for (final t in tips)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.bolt_rounded, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
          if (comparable && (result['photo_tips'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('📸 ${result['photo_tips']}', style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Home-screen card: latest photos + quick add + compare.
class ProgressPhotosHomeCard extends ConsumerWidget {
  const ProgressPhotosHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final photos = ref.watch(progressPhotosProvider).value ?? const <ProgressPhoto>[];
    final last = photos.isEmpty ? null : photos.first;
    final daysSince = last == null ? null : DateTime.now().difference(last.timestamp).inDays;

    return AppCard(
      onTap: () => context.push('/progress/photos'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: Icons.photo_camera_front_rounded, color: AppColors.violet, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.photosTitle, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      last == null ? l10n.photosHomeEmpty : l10n.photosHomeLast(daysSince!),
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: l10n.photosAdd,
                icon: const Icon(Icons.add_a_photo_rounded),
                onPressed: () => addProgressPhoto(context, ref),
              ),
            ],
          ),
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final ph in photos.take(8))
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: SizedBox(width: 72, child: PhotoThumb(photo: ph, label: DateFormat.Md(locale).format(ph.timestamp))),
                    ),
                ],
              ),
            ),
            if (photos.length >= 2) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(child: Text(l10n.photosHomeCompare, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700))),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
