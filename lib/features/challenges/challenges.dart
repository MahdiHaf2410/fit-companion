import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../social/social.dart' show FriendsEntryTile, ShareStat, showShareCard;

// =============================================================================
// Model
// =============================================================================

enum ChallengePeriod { week, month }

class ChallengeDef {
  final String id;
  final ChallengePeriod period;
  final IconData icon;
  final Color color;
  final double target;
  final int xp;

  const ChallengeDef(this.id, this.period, this.icon, this.color, this.target, this.xp);
}

class ChallengeProgress {
  final ChallengeDef def;
  final double value;
  final DateTime periodEnd;

  ChallengeProgress(this.def, this.value, this.periodEnd);

  bool get done => value >= def.target;
  double get ratio => (value / def.target).clamp(0.0, 1.0);
  int get daysLeft => math.max(0, periodEnd.difference(DateTime.now()).inDays + 1);
}

final challengeDefs = <ChallengeDef>[
  ChallengeDef('w_workouts', ChallengePeriod.week, Icons.fitness_center_rounded, AppColors.violet, 4, 150),
  ChallengeDef('w_protein', ChallengePeriod.week, Icons.egg_alt_rounded, AppColors.protein, 5, 120),
  ChallengeDef('w_water', ChallengePeriod.week, Icons.water_drop_rounded, AppColors.water, 5, 100),
  ChallengeDef('w_log', ChallengePeriod.week, Icons.restaurant_rounded, AppColors.carbs, 7, 100),
  ChallengeDef('m_workouts', ChallengePeriod.month, Icons.calendar_month_rounded, AppColors.lime, 16, 400),
  ChallengeDef('m_prs', ChallengePeriod.month, Icons.emoji_events_rounded, AppColors.carbs, 3, 300),
  ChallengeDef('m_volume', ChallengePeriod.month, Icons.stacked_bar_chart_rounded, AppColors.cyan, 50000, 350),
  ChallengeDef('m_weigh', ChallengePeriod.month, Icons.monitor_weight_rounded, AppColors.fat, 8, 200),
];

/// Level curve: level n needs 100·n·(n−1)/2 XP (100, 300, 600, 1000…).
class LevelInfo {
  final int xp;
  LevelInfo(this.xp);

  int get level => ((math.sqrt(1 + 8 * xp / 100) + 1) / 2).floor();
  int xpFor(int lvl) => (100 * lvl * (lvl - 1) / 2).round();
  int get currentFloor => xpFor(level);
  int get nextFloor => xpFor(level + 1);
  double get progress => (xp - currentFloor) / math.max(1, nextFloor - currentFloor);
}

/// Week starts on Saturday (Algerian week).
DateTime weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: (day.weekday + 1) % 7));
}

class GamificationState {
  final List<ChallengeProgress> challenges;
  final LevelInfo level;
  final Map<String, int> xpBreakdown;
  final Set<String> newlyCompleted; // challenge ids completed since last check

  GamificationState(this.challenges, this.level, this.xpBreakdown, this.newlyCompleted);
}

// =============================================================================
// Repository
// =============================================================================

class ChallengesRepository {
  final AppDatabase db;
  ChallengesRepository(this.db);

  static const _doneKey = 'challenges_done';

  static String _ymd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Stream<GamificationState> watch() => db
      .customSelect('SELECT 1', readsFrom: {db.workoutSessions, db.workoutSets, db.foodLogs, db.bodyMetrics, db.appPreferences, db.goals})
      .watch()
      .asyncMap((_) => compute());

  Future<GamificationState> compute({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final wStart = weekStart(today);
    final wEnd = wStart.add(const Duration(days: 6));
    final mStart = DateTime(today.year, today.month, 1);
    final mEnd = DateTime(today.year, today.month + 1, 0);

    final goal = await (db.select(db.goals)..limit(1)).getSingleOrNull();
    final proteinTarget = goal?.targetProteinGrams ?? 150;

    final sessions = await (db.select(db.workoutSessions)..where((s) => s.status.equals('completed'))).get();
    final prSets = await (db.select(db.workoutSets)..where((s) => s.isPersonalRecord.equals(true) & s.isCompleted.equals(true))).get();
    final logs = await (db.select(db.foodLogs)..where((l) => l.isEaten.equals(true))).get();
    final metrics = await db.select(db.bodyMetrics).get();
    final prefs = await (db.select(db.appPreferences)..where((p) => p.key.like('water_%'))).get();
    final waterGoal = int.tryParse(prefs.where((p) => p.key == 'water_goal_ml').firstOrNull?.value ?? '') ?? 2500;

    bool inRange(DateTime d, DateTime a, DateTime b) => !d.isBefore(a) && d.isBefore(b.add(const Duration(days: 1)));
    DateTime parse(String ymd) {
      final p = ymd.split('-').map(int.parse).toList();
      return DateTime(p[0], p[1], p[2]);
    }

    // Daily aggregates
    final proteinByDay = <String, double>{};
    for (final l in logs) {
      proteinByDay[l.date] = (proteinByDay[l.date] ?? 0) + l.protein;
    }
    final waterDays = <String>{
      for (final p in prefs)
        if (p.key != 'water_goal_ml' && (int.tryParse(p.value) ?? 0) >= waterGoal) p.key.substring(6),
    };

    double value(ChallengeDef d) {
      final (a, b) = d.period == ChallengePeriod.week ? (wStart, wEnd) : (mStart, mEnd);
      switch (d.id) {
        case 'w_workouts':
        case 'm_workouts':
          return sessions.where((s) => inRange(s.startTime, a, b)).length.toDouble();
        case 'w_protein':
          return proteinByDay.entries.where((e) => inRange(parse(e.key), a, b) && e.value >= proteinTarget * 0.95).length.toDouble();
        case 'w_water':
          return waterDays.where((k) => inRange(parse(k), a, b)).length.toDouble();
        case 'w_log':
          return proteinByDay.keys.where((k) => inRange(parse(k), a, b)).length.toDouble();
        case 'm_prs':
          return prSets.where((s) => s.completedAt != null && inRange(s.completedAt!, a, b)).length.toDouble();
        case 'm_volume':
          return sessions.where((s) => inRange(s.startTime, a, b)).fold<double>(0, (x, s) => x + s.totalVolumeKg);
        case 'm_weigh':
          return metrics.where((m) => inRange(m.timestamp, a, b)).length.toDouble();
      }
      return 0;
    }

    final challenges = [
      for (final d in challengeDefs) ChallengeProgress(d, value(d), d.period == ChallengePeriod.week ? wEnd : mEnd),
    ];

    // Persist completions (id@periodStart) so finished challenges keep their XP forever.
    final doneRow = await (db.select(db.appPreferences)..where((p) => p.key.equals(_doneKey))).getSingleOrNull();
    final done = (doneRow?.value ?? '').split(',').where((e) => e.isNotEmpty).toSet();
    final fresh = <String>{};
    for (final c in challenges.where((c) => c.done)) {
      final key = '${c.def.id}@${_ymd(c.def.period == ChallengePeriod.week ? wStart : mStart)}';
      if (done.add(key)) fresh.add(c.def.id);
    }
    if (fresh.isNotEmpty) {
      await db.into(db.appPreferences).insertOnConflictUpdate(
            AppPreferencesCompanion(key: const Value(_doneKey), value: Value(done.join(','))),
          );
    }
    int challengeXp = 0;
    for (final k in done) {
      final id = k.split('@').first;
      challengeXp += challengeDefs.where((d) => d.id == id).firstOrNull?.xp ?? 0;
    }

    final breakdown = <String, int>{
      'workouts': sessions.length * 50,
      'prs': prSets.length * 30,
      'food': proteinByDay.length * 10,
      'water': waterDays.length * 10,
      'weigh': metrics.length * 5,
      'challenges': challengeXp,
    };
    final xp = breakdown.values.fold<int>(0, (a, b) => a + b);
    return GamificationState(challenges, LevelInfo(xp), breakdown, fresh);
  }
}

final challengesRepositoryProvider = Provider<ChallengesRepository>((ref) => ChallengesRepository(ref.watch(databaseProvider)));
final gamificationProvider = StreamProvider<GamificationState>((ref) => ref.watch(challengesRepositoryProvider).watch());

// =============================================================================
// UI
// =============================================================================

String challengeTitle(AppLocalizations l10n, ChallengeDef d) => switch (d.id) {
      'w_workouts' => l10n.chWorkouts(d.target.toInt()),
      'w_protein' => l10n.chProtein(d.target.toInt()),
      'w_water' => l10n.chWater(d.target.toInt()),
      'w_log' => l10n.chLog(d.target.toInt()),
      'm_workouts' => l10n.chWorkouts(d.target.toInt()),
      'm_prs' => l10n.chPrs(d.target.toInt()),
      'm_volume' => l10n.chVolume((d.target / 1000).toStringAsFixed(0)),
      'm_weigh' => l10n.chWeigh(d.target.toInt()),
      _ => d.id,
    };

String levelTitle(AppLocalizations l10n, int level) {
  if (level >= 30) return l10n.lvlLegend;
  if (level >= 20) return l10n.lvlBeast;
  if (level >= 12) return l10n.lvlWarrior;
  if (level >= 6) return l10n.lvlAthlete;
  if (level >= 3) return l10n.lvlRookie;
  return l10n.lvlBeginner;
}

class _ChallengeTile extends StatelessWidget {
  final ChallengeProgress c;
  const _ChallengeTile({required this.c});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final color = c.def.color;
    String fmt(double v) => c.def.id == 'm_volume' ? '${(v / 1000).toStringAsFixed(1)}t' : v.toInt().toString();
    return AppCard(
      padding: const EdgeInsets.all(14),
      border: c.done ? Border.all(color: AppColors.success.withValues(alpha: 0.6), width: 1.5) : null,
      child: Row(
        children: [
          IconBadge(icon: c.done ? Icons.check_rounded : c.def.icon, color: c.done ? AppColors.success : color, size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challengeTitle(l10n, c.def), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: c.ratio, minHeight: 6, color: c.done ? AppColors.success : color),
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt(c.value)} / ${fmt(c.def.target)} • ${c.done ? l10n.chDone : l10n.chDaysLeft(c.daysLeft)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(label: '+${c.def.xp} XP', color: c.done ? AppColors.success : color),
        ],
      ),
    );
  }
}

class _LevelHeader extends StatelessWidget {
  final LevelInfo level;
  const _LevelHeader({required this.level});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        ProgressRing(
          progress: level.progress,
          size: 74,
          strokeWidth: 8,
          color: theme.colorScheme.primary,
          gradient: context.accentGradient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${level.level}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1)),
              Text('LVL', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(levelTitle(l10n, level.level), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              Text('${level.xp} XP', style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(l10n.xpToNext(level.nextFloor - level.xp, level.level + 1), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final s = ref.watch(gamificationProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chTitle),
        actions: [
          if (s != null)
            IconButton(
              tooltip: l10n.shareAction,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => showShareCard(
                context,
                title: '${l10n.friendsLevel(s.level.level)} · ${levelTitle(l10n, s.level.level)}',
                subtitle: '${s.level.xp} XP',
                badge: 'LVL ${s.level.level}',
                stats: [
                  for (final c in s.challenges.where((c) => c.done))
                    ShareStat(c.def.icon, '✓', challengeTitle(l10n, c.def), c.def.color),
                  if (s.challenges.every((c) => !c.done))
                    ShareStat(Icons.bolt_rounded, '${s.level.xp}', 'XP', AppColors.lime),
                ],
              ),
            ),
        ],
      ),
      body: s == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
              children: [
                AppCard(gradient: context.heroGradient, child: _LevelHeader(level: s.level)),
                const SizedBox(height: 10),
                const FriendsEntryTile(),
                SectionHeader(title: l10n.chWeekly),
                for (final c in s.challenges.where((c) => c.def.period == ChallengePeriod.week))
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: _ChallengeTile(c: c)),
                SectionHeader(title: l10n.chMonthly),
                for (final c in s.challenges.where((c) => c.def.period == ChallengePeriod.month))
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: _ChallengeTile(c: c)),
                SectionHeader(title: l10n.xpHowTitle),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final e in s.xpBreakdown.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  switch (e.key) {
                                    'workouts' => l10n.xpWorkouts,
                                    'prs' => l10n.xpPrs,
                                    'food' => l10n.xpFood,
                                    'water' => l10n.xpWater,
                                    'weigh' => l10n.xpWeigh,
                                    _ => l10n.xpChallenges,
                                  },
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Text('${e.value} XP', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Dashboard card: level + the two challenges closest to completion.
class ChallengesHomeCard extends ConsumerStatefulWidget {
  const ChallengesHomeCard({super.key});

  @override
  ConsumerState<ChallengesHomeCard> createState() => _ChallengesHomeCardState();
}

class _ChallengesHomeCardState extends ConsumerState<ChallengesHomeCard> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(gamificationProvider, (_, next) {
      final s = next.value;
      if (s == null || s.newlyCompleted.isEmpty || !mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final def = challengeDefs.firstWhere((d) => d.id == s.newlyCompleted.first);
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🎯 ${l10n.chCompleted}: ${challengeTitle(l10n, def)} (+${def.xp} XP)')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gamificationProvider).value;
    if (s == null) return const SizedBox.shrink();
    final open = s.challenges.where((c) => !c.done).toList()..sort((a, b) => b.ratio.compareTo(a.ratio));
    return AppCard(
      onTap: () => context.push('/challenges'),
      child: Column(
        children: [
          _LevelHeader(level: s.level),
          for (final c in open.take(2)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(c.def.icon, size: 18, color: c.def.color),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challengeTitle(AppLocalizations.of(context)!, c.def),
                          maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(value: c.ratio, minHeight: 5, color: c.def.color),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
