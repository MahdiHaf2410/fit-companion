import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../core/database/app_database.dart';
import '../../core/services/cloud_service.dart';
import '../../core/services/health_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/insights.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/settings_provider.dart';
import '../challenges/challenges.dart';
import '../coach/coach_context.dart';
import '../profile/presentation/profile_providers.dart';

// =============================================================================
// Shared helpers
// =============================================================================

String aiErrorText(AppLocalizations l10n, String code) => switch (code) {
      'missing_gemini_key' || 'gemini_key' => l10n.coachErrNoKey,
      'gemini_model' => l10n.coachErrModel,
      'gemini_busy' || 'bad_ai_output' => l10n.coachErrBusy,
      'unauthorized' => l10n.coachNeedsAccount,
      'daily_limit' => l10n.coachErrLimit,
      'gemini_quota' => l10n.coachErrQuota,
      _ => l10n.coachErrGeneric,
    };

Future<String?> _readPref(AppDatabase db, String key) async =>
    (await (db.select(db.appPreferences)..where((p) => p.key.equals(key))).getSingleOrNull())?.value;

Future<void> _writePref(AppDatabase db, String key, String value) =>
    db.into(db.appPreferences).insertOnConflictUpdate(AppPreferencesCompanion(key: Value(key), value: Value(value)));

String _mealForTime(String hhmm) {
  final h = int.tryParse(hhmm.split(':').first) ?? 12;
  if (h < 11) return 'breakfast';
  if (h < 16) return 'lunch';
  if (h < 19) return 'snack';
  return 'dinner';
}

/// Runs an AI call with a loading state and maps errors to a snackbar.
Future<Map<String, dynamic>?> _runAi(BuildContext context, WidgetRef ref, String mode, Map<String, dynamic> body) async {
  final l10n = AppLocalizations.of(context)!;
  final cloud = ref.read(cloudServiceProvider);
  if (cloud.user == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l10n.coachNeedsAccount),
      action: SnackBarAction(label: l10n.aiSignIn, onPressed: () => context.push('/settings/cloud')),
    ));
    return null;
  }
  try {
    return await cloud.aiTool(mode, language: ref.read(localeProvider).languageCode, body: body);
  } on CoachException catch (e) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(aiErrorText(l10n, e.code))));
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.coachErrGeneric)));
  }
  return null;
}

class _Bullets extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  final IconData icon;
  final Color color;
  const _Bullets({required this.title, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 8),
            for (final s in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: const EdgeInsets.only(top: 7), child: Icon(Icons.circle, size: 6, color: color)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(s.toString(), style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Busy extends StatelessWidget {
  final String text;
  const _Busy(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 14),
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ]),
      );
}

// =============================================================================
// Dashboard entry card
// =============================================================================

class AiToolsCard extends StatelessWidget {
  const AiToolsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiles = [
      (Icons.summarize_rounded, l10n.aiReportTitle, AppColors.violet, () => context.push('/ai/report')),
      (Icons.auto_awesome_rounded, l10n.aiProgramTitle, AppColors.lime, () => context.push('/ai/program')),
      (Icons.restaurant_menu_rounded, l10n.aiMealTitle, AppColors.carbs, () => context.push('/ai/meals')),
      (Icons.mic_rounded, l10n.aiVoiceTitle, AppColors.cyan, () => showVoiceLogSheet(context)),
    ];
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(l10n.aiToolsTitle, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              for (final t in tiles)
                Material(
                  color: t.$3.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: t.$4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(children: [
                        Icon(t.$1, color: t.$3, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(t.$2,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                      ]),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 1. Weekly AI report
// =============================================================================

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  static const _key = 'ai_weekly_report';
  static const _remindKey = 'ai_weekly_remind';
  Map<String, dynamic>? _report;
  DateTime? _date;
  bool _busy = false;
  bool _remind = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final raw = await _readPref(db, _key);
    final remind = await _readPref(db, _remindKey);
    if (!mounted) return;
    setState(() {
      _remind = remind == '1';
      if (raw != null) {
        try {
          final j = jsonDecode(raw) as Map<String, dynamic>;
          _date = DateTime.tryParse(j['date'] as String? ?? '');
          _report = Map<String, dynamic>.from(j['data'] as Map);
        } catch (_) {}
      }
    });
  }

  Future<String> _context() async {
    final db = ref.read(databaseProvider);
    final base = await CoachContextBuilder(db).build();
    final lines = <String>[base];
    final g = await ref.read(challengesRepositoryProvider).compute();
    final week = g.challenges.where((c) => c.def.period == ChallengePeriod.week);
    lines.add('This week (Sat→Fri): ${week.map((c) => '${c.def.id} ${c.value.toStringAsFixed(0)}/${c.def.target.toStringAsFixed(0)}').join(', ')}.');
    lines.add('Level ${g.level.level}, ${g.level.xp} XP.');
    final volume = g.challenges.firstWhere((c) => c.def.id == 'm_volume').value;
    lines.add('Volume this month: ${volume.toStringAsFixed(0)} kg.');
    final tdee = await InsightsRepositoryLite(db).tdee();
    if (tdee != null) lines.add('Measured TDEE: ${tdee.tdee.round()} kcal (weight ${tdee.weeklyChangeKg.toStringAsFixed(2)} kg/week).');
    final sleep = await ref.read(healthServiceProvider).sleepByNight(7);
    if (sleep.isNotEmpty) {
      lines.add('Sleep last 7 nights: avg ${(sleep.values.reduce((a, b) => a + b) / sleep.length).toStringAsFixed(1)} h (${sleep.length} nights).');
    }
    return lines.join('\n');
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    final ctx = await _context();
    if (!mounted) return;
    final r = await _runAi(context, ref, 'weekly_report', {'context': ctx});
    if (r != null) {
      final now = DateTime.now();
      await _writePref(ref.read(databaseProvider), _key, jsonEncode({'date': now.toIso8601String(), 'data': r}));
      _report = r;
      _date = now;
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _toggleRemind(bool v) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _remind = v);
    await _writePref(ref.read(databaseProvider), _remindKey, v ? '1' : '0');
    await ref.read(notificationServiceProvider).scheduleWeeklyReport(enabled: v, title: l10n.aiReportNotifTitle, body: l10n.aiReportNotifBody);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final r = _report;
    final score = (r?['score'] as num?)?.toDouble() ?? 0;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiReportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.aiReportIntro, style: theme.textTheme.bodyMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _remind,
            onChanged: _toggleRemind,
            title: Text(l10n.aiReportRemind),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(r == null ? l10n.aiGenerate : l10n.aiRegenerate),
          ),
          if (_busy) _Busy(l10n.aiThinking),
          if (!_busy && r != null) ...[
            const SizedBox(height: 16),
            AppCard(
              gradient: context.heroGradient,
              child: Row(children: [
                ProgressRing(
                  progress: score / 10,
                  size: 70,
                  strokeWidth: 8,
                  color: theme.colorScheme.primary,
                  gradient: context.accentGradient,
                  child: Text(score.toStringAsFixed(score % 1 == 0 ? 0 : 1),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r['headline']?.toString() ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    if (_date != null)
                      Text(MaterialLocalizations.of(context).formatMediumDate(_date!), style: theme.textTheme.bodySmall),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 12),
            AppCard(child: Text(r['summary']?.toString() ?? '', style: theme.textTheme.bodyMedium)),
            _Bullets(title: l10n.aiWins, items: r['wins'] as List? ?? const [], icon: Icons.emoji_events_rounded, color: AppColors.success),
            _Bullets(title: l10n.aiImprove, items: r['improve'] as List? ?? const [], icon: Icons.trending_up_rounded, color: AppColors.carbs),
            _Bullets(title: l10n.aiNextWeek, items: r['next_week'] as List? ?? const [], icon: Icons.flag_rounded, color: AppColors.violet),
          ],
        ],
      ),
    );
  }
}

/// Minimal TDEE reader (avoids importing the insights UI file here).
class InsightsRepositoryLite {
  final AppDatabase db;
  InsightsRepositoryLite(this.db);

  Future<TdeeResult?> tdee() async {
    final since = DateTime.now().subtract(const Duration(days: 35));
    final logs = await (db.select(db.foodLogs)..where((l) => l.isEaten.equals(true) & l.timestamp.isBiggerOrEqualValue(since))).get();
    final daily = <DateTime, double>{};
    for (final l in logs) {
      final p = l.date.split('-').map(int.parse).toList();
      final d = DateTime(p[0], p[1], p[2]);
      daily[d] = (daily[d] ?? 0) + l.calories;
    }
    final metrics = await (db.select(db.bodyMetrics)..where((m) => m.timestamp.isBiggerOrEqualValue(since))).get();
    return AdaptiveTdee.compute(dailyIntake: daily, weights: [for (final m in metrics) (m.timestamp, m.weightKg)]);
  }
}

// =============================================================================
// 2. AI program builder
// =============================================================================

class ProgramBuilderScreen extends ConsumerStatefulWidget {
  const ProgramBuilderScreen({super.key});

  @override
  ConsumerState<ProgramBuilderScreen> createState() => _ProgramBuilderScreenState();
}

class _ProgramBuilderScreenState extends ConsumerState<ProgramBuilderScreen> {
  int _days = 4;
  String _goal = 'hypertrophy';
  final _equipment = <String>{'barbell', 'dumbbell', 'cable', 'machine', 'bodyweight', 'kettlebell', 'band'};
  final _notes = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _result;
  Map<String, Exercise> _byId = {};

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _result = null;
    });
    final db = ref.read(databaseProvider);
    final all = await db.select(db.exercises).get();
    _byId = {for (final e in all) e.id: e};
    final catalogue = all.where((e) => _equipment.contains(e.equipment)).map((e) => '${e.id}|${e.name}|${e.muscleGroup}|${e.equipment}').join('\n');
    final ctx = await CoachContextBuilder(db).build();
    if (!mounted) return;
    final r = await _runAi(context, ref, 'program', {
      'context': ctx,
      'catalogue': catalogue,
      'request': 'Training days per week: $_days. Goal: $_goal. Equipment: ${_equipment.join(', ')}. Notes: ${_notes.text.trim()}',
    });
    if (mounted) {
      setState(() {
        _busy = false;
        _result = r;
      });
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final r = _result!;
    final repo = ref.read(workoutRepositoryProvider);
    final base = r['name']?.toString() ?? 'AI';
    for (final d in (r['days'] as List)) {
      final day = Map<String, dynamic>.from(d as Map);
      await repo.saveProgram(
        name: '$base – ${day['name']}',
        description: r['description']?.toString(),
        exercises: [
          for (final e in (day['exercises'] as List))
            {
              'exerciseId': (e as Map)['exercise_id'],
              'targetSets': e['sets'],
              'targetReps': e['reps'],
              'targetRestSeconds': e['rest_seconds'],
            },
        ],
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiProgramSaved)));
    context.go('/workouts');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final goals = {
      'strength': l10n.aiGoalStrength,
      'hypertrophy': l10n.aiGoalMuscle,
      'fat_loss': l10n.aiGoalFatLoss,
      'endurance': l10n.aiGoalEndurance,
    };
    final equip = {
      'barbell': l10n.aiEqBarbell,
      'dumbbell': l10n.aiEqDumbbell,
      'cable': l10n.aiEqCable,
      'machine': l10n.aiEqMachine,
      'bodyweight': l10n.aiEqBodyweight,
      'kettlebell': l10n.equipKettlebell,
      'band': l10n.equipBand,
    };
    final r = _result;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiProgramTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.aiProgramDays(_days), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          Slider(value: _days.toDouble(), min: 2, max: 6, divisions: 4, label: '$_days', onChanged: (v) => setState(() => _days = v.round())),
          Text(l10n.aiProgramGoal, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final g in goals.entries)
              ChoiceChip(label: Text(g.value), selected: _goal == g.key, onSelected: (_) => setState(() => _goal = g.key)),
          ]),
          const SizedBox(height: 14),
          Text(l10n.aiProgramEquipment, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final e in equip.entries)
              FilterChip(
                label: Text(e.value),
                selected: _equipment.contains(e.key),
                onSelected: (v) => setState(() {
                  if (v) {
                    _equipment.add(e.key);
                  } else if (_equipment.length > 1) {
                    _equipment.remove(e.key);
                  }
                }),
              ),
          ]),
          const SizedBox(height: 14),
          TextField(
            controller: _notes,
            maxLength: 300,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.aiProgramNotes, hintText: l10n.aiProgramNotesHint),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(r == null ? l10n.aiGenerate : l10n.aiRegenerate),
          ),
          if (_busy) _Busy(l10n.aiThinking),
          if (!_busy && r != null) ...[
            const SizedBox(height: 16),
            AppCard(
              gradient: context.heroGradient,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r['name']?.toString() ?? '', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(r['description']?.toString() ?? '', style: theme.textTheme.bodySmall),
              ]),
            ),
            for (final d in (r['days'] as List))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text((d as Map)['name']?.toString() ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    for (final e in (d['exercises'] as List))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(children: [
                          Expanded(
                            child: Text(
                              () {
                                final ex = _byId[(e as Map)['exercise_id']];
                                return ex == null ? e['exercise_id'].toString() : (isAr ? (ex.nameAr ?? ex.name) : ex.name);
                              }(),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text('${e['sets']}×${e['reps']}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
                        ]),
                      ),
                  ]),
                ),
              ),
            _Bullets(title: l10n.aiTips, items: r['notes'] as List? ?? const [], icon: Icons.lightbulb_rounded, color: AppColors.carbs),
            const SizedBox(height: 14),
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_rounded), label: Text(l10n.aiProgramSave)),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// 3. AI meal plan
// =============================================================================

class MealPlanScreen extends ConsumerStatefulWidget {
  const MealPlanScreen({super.key});

  @override
  ConsumerState<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends ConsumerState<MealPlanScreen> {
  static const _key = 'ai_meal_plan';
  final _request = TextEditingController();
  bool _busy = false;
  Map<String, dynamic>? _plan;
  final _added = <int>{};

  @override
  void initState() {
    super.initState();
    _readPref(ref.read(databaseProvider), _key).then((raw) {
      if (raw == null || !mounted) return;
      try {
        setState(() => _plan = Map<String, dynamic>.from(jsonDecode(raw) as Map));
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _request.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    setState(() => _busy = true);
    final db = ref.read(databaseProvider);
    final ctx = await CoachContextBuilder(db).build();
    if (!mounted) return;
    final r = await _runAi(context, ref, 'meal_plan', {'context': ctx, 'request': _request.text.trim()});
    if (r != null) {
      await _writePref(db, _key, jsonEncode(r));
      _plan = r;
      _added.clear();
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _addMeal(int i, Map meal) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(nutritionRepositoryProvider);
    final now = DateTime.now();
    final p = (meal['time']?.toString() ?? '12:00').split(':');
    final at = DateTime(now.year, now.month, now.day, int.tryParse(p.first) ?? 12, p.length > 1 ? int.tryParse(p[1]) ?? 0 : 0);
    for (final it in (meal['items'] as List)) {
      final m = it as Map;
      await repo.logCustomEntry(
        name: m['name'].toString(),
        grams: (m['grams'] as num).toDouble(),
        calories: (m['kcal'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        mealType: _mealForTime(meal['time']?.toString() ?? '12:00'),
        timestamp: at,
        isEaten: false,
      );
    }
    setState(() => _added.add(i));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiMealAdded)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final goal = ref.watch(goalStreamProvider).value;
    final plan = _plan;
    double sum(String k) {
      double t = 0;
      for (final m in (plan?['meals'] as List? ?? const [])) {
        for (final it in ((m as Map)['items'] as List)) {
          t += ((it as Map)[k] as num).toDouble();
        }
      }
      return t;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aiMealTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.aiMealIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          TextField(
            controller: _request,
            maxLength: 300,
            maxLines: 2,
            decoration: InputDecoration(labelText: l10n.aiMealRequest, hintText: l10n.aiMealRequestHint),
          ),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(plan == null ? l10n.aiGenerate : l10n.aiRegenerate),
          ),
          if (_busy) _Busy(l10n.aiThinking),
          if (!_busy && plan != null) ...[
            const SizedBox(height: 16),
            AppCard(
              gradient: context.heroGradient,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                for (final m in [
                  ('kcal', l10n.aiKcal, goal?.targetCalories.toDouble(), AppColors.flame),
                  ('protein', 'P', goal?.targetProteinGrams, AppColors.protein),
                  ('carbs', 'C', goal?.targetCarbsGrams, AppColors.carbs),
                  ('fat', 'F', goal?.targetFatGrams, AppColors.fat),
                ])
                  Column(children: [
                    Text(sum(m.$1).round().toString(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: m.$4)),
                    Text(m.$3 == null ? m.$2 : '${m.$2} / ${m.$3!.round()}', style: theme.textTheme.labelSmall),
                  ]),
              ]),
            ),
            for (final (i, meal) in (plan['meals'] as List).indexed)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Pill(label: (meal as Map)['time']?.toString() ?? '', color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(meal['name']?.toString() ?? '', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                    ]),
                    const SizedBox(height: 8),
                    for (final it in (meal['items'] as List))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(children: [
                          Expanded(child: Text('${(it as Map)['name']} · ${(it['grams'] as num).round()} g', style: theme.textTheme.bodyMedium)),
                          Text('${(it['kcal'] as num).round()} kcal · P ${(it['protein'] as num).round()}',
                              style: theme.textTheme.bodySmall),
                        ]),
                      ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: _added.contains(i) ? null : () => _addMeal(i, meal),
                        icon: Icon(_added.contains(i) ? Icons.check_rounded : Icons.add_rounded),
                        label: Text(_added.contains(i) ? l10n.aiMealAddedShort : l10n.aiMealAdd),
                      ),
                    ),
                  ]),
                ),
              ),
            _Bullets(
                title: l10n.aiShopping, items: plan['shopping_list'] as List? ?? const [], icon: Icons.shopping_cart_rounded, color: AppColors.cyan),
            _Bullets(title: l10n.aiTips, items: plan['tips'] as List? ?? const [], icon: Icons.lightbulb_rounded, color: AppColors.carbs),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// 4. Voice food logging
// =============================================================================

Future<void> showVoiceLogSheet(BuildContext context, {String? mealType}) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _VoiceLogSheet(mealType: mealType),
    );

class _VoiceLogSheet extends ConsumerStatefulWidget {
  final String? mealType;
  const _VoiceLogSheet({this.mealType});

  @override
  ConsumerState<_VoiceLogSheet> createState() => _VoiceLogSheetState();
}

class _VoiceLogSheetState extends ConsumerState<_VoiceLogSheet> {
  final _rec = AudioRecorder();
  bool _recording = false;
  bool _busy = false;
  String? _transcript;
  List<Map<String, dynamic>> _items = [];
  final _selected = <int>{};
  late String _meal = widget.mealType ?? _mealForTime('${DateTime.now().hour}:00');
  DateTime? _startedAt;

  @override
  void dispose() {
    _rec.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context)!;
    if (_recording) {
      final path = await _rec.stop();
      setState(() => _recording = false);
      if (path == null) return;
      final file = File(path);
      final bytes = await file.readAsBytes();
      try {
        await file.delete();
      } catch (_) {}
      if (_startedAt != null && DateTime.now().difference(_startedAt!).inMilliseconds < 800) return;
      setState(() => _busy = true);
      if (!mounted) return;
      final r = await _runAi(context, ref, 'voice_log', {
        'audio': {'data': base64Encode(bytes), 'mime': 'audio/wav'},
      });
      if (!mounted) return;
      setState(() {
        _busy = false;
        if (r != null) {
          _transcript = r['transcript']?.toString();
          _items = [for (final i in (r['items'] as List? ?? const [])) Map<String, dynamic>.from(i as Map)];
          _selected
            ..clear()
            ..addAll(List.generate(_items.length, (i) => i));
        }
      });
      return;
    }
    if (ref.read(cloudServiceProvider).user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.coachNeedsAccount)));
      return;
    }
    if (!await _rec.hasPermission()) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiVoiceNoMic)));
      return;
    }
    final dir = await getTemporaryDirectory();
    await _rec.start(
      const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
      path: '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    _startedAt = DateTime.now();
    setState(() {
      _recording = true;
      _transcript = null;
      _items = [];
    });
  }

  Future<void> _log() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(nutritionRepositoryProvider);
    final now = DateTime.now();
    for (final i in _selected) {
      final m = _items[i];
      await repo.logCustomEntry(
        name: m['name'].toString(),
        grams: (m['grams'] as num).toDouble(),
        calories: (m['kcal'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        mealType: _meal,
        timestamp: now,
        isEaten: true,
        eatenAt: now,
      );
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.aiVoiceLogged(_selected.length))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final meals = {
      'breakfast': l10n.nutritionMealBreakfast,
      'lunch': l10n.nutritionMealLunch,
      'dinner': l10n.nutritionMealDinner,
      'snack': l10n.nutritionMealSnacks,
    };
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.aiVoiceTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(l10n.aiVoiceHint, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _busy ? null : _toggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: _recording ? 96 : 84,
                  height: _recording ? 96 : 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _recording ? AppColors.flame : theme.colorScheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: (_recording ? AppColors.flame : theme.colorScheme.primary).withValues(alpha: 0.45),
                        blurRadius: _recording ? 30 : 14,
                      ),
                    ],
                  ),
                  child: _busy
                      ? Padding(padding: const EdgeInsets.all(28), child: CircularProgressIndicator(color: theme.colorScheme.onPrimary))
                      : Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded, size: 40, color: AppColors.active.onColor(_recording ? AppColors.flame : theme.colorScheme.primary)),
                ),
              ),
              const SizedBox(height: 10),
              Text(_recording ? l10n.aiVoiceListening : (_busy ? l10n.aiThinking : l10n.aiVoiceTap), style: theme.textTheme.bodySmall),
              if (_transcript != null) ...[
                const SizedBox(height: 14),
                AppCard(child: Text('“$_transcript”', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic))),
              ],
              if (_transcript != null && _items.isEmpty)
                Padding(padding: const EdgeInsets.only(top: 10), child: Text(l10n.aiVoiceNothing, style: theme.textTheme.bodySmall)),
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final (i, m) in _items.indexed)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selected.contains(i),
                    onChanged: (v) => setState(() => v == true ? _selected.add(i) : _selected.remove(i)),
                    title: Text('${m['name']} · ${(m['grams'] as num).round()} g'),
                    subtitle: Text(
                        '${(m['kcal'] as num).round()} kcal · P ${(m['protein'] as num).round()} · C ${(m['carbs'] as num).round()} · F ${(m['fat'] as num).round()}'),
                  ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [for (final e in meals.entries) ButtonSegment(value: e.key, label: Text(e.value, overflow: TextOverflow.ellipsis))],
                  selected: {_meal},
                  onSelectionChanged: (s) => setState(() => _meal = s.first),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _selected.isEmpty ? null : _log,
                    icon: const Icon(Icons.check_rounded),
                    label: Text(l10n.aiVoiceLog(_selected.length)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
