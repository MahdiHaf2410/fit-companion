import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/cloud_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'eaten_widgets.dart';
import 'nutrition_providers.dart';

/// Add your own food: name + description + weight → AI computes calories and
/// macros for that portion (editable), then save it and optionally log it.
class MyFoodScreen extends ConsumerStatefulWidget {
  final String? mealType;

  const MyFoodScreen({super.key, this.mealType});

  @override
  ConsumerState<MyFoodScreen> createState() => _MyFoodScreenState();
}

class _MyFoodScreenState extends ConsumerState<MyFoodScreen> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _grams = TextEditingController(text: '250');
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  double _fiber100 = 0;

  bool _analyzing = false;
  bool _saving = false;
  FoodMacroEstimate? _estimate;
  String? _error;

  late String _meal = widget.mealType ?? _guessMeal();
  bool _logNow = true;
  bool _eaten = true;
  TimeOfDay _time = TimeOfDay.now();

  static String _guessMeal() {
    final h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 16) return 'lunch';
    if (h < 22) return 'dinner';
    return 'snack';
  }

  @override
  void dispose() {
    for (final c in [_name, _desc, _grams, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.tryParse(c.text.replaceAll(',', '.')) ?? 0;
  String _fmt(double v) => v.toStringAsFixed(v >= 100 ? 0 : 1);

  /// When the weight changes after an AI estimate, rescale the portion values.
  void _rescale() {
    final e = _estimate;
    final g = _num(_grams);
    if (e == null || g <= 0) return;
    setState(() {
      _kcal.text = _fmt(e.kcal100 * g / 100);
      _protein.text = _fmt(e.protein100 * g / 100);
      _carbs.text = _fmt(e.carbs100 * g / 100);
      _fat.text = _fmt(e.fat100 * g / 100);
    });
  }

  Future<void> _analyze() async {
    final l10n = AppLocalizations.of(context)!;
    final grams = _num(_grams);
    if (_name.text.trim().isEmpty || grams <= 0) {
      setState(() => _error = l10n.myFoodNeedNameWeight);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _analyzing = true;
      _error = null;
    });
    try {
      final e = await ref.read(cloudServiceProvider).estimateFoodMacros(
            name: _name.text.trim(),
            description: _desc.text.trim(),
            grams: grams,
            language: ref.read(localeProvider).languageCode,
          );
      HapticFeedback.mediumImpact();
      _estimate = e;
      _fiber100 = e.fiber100;
      _rescale();
    } on CoachException catch (e) {
      setState(() => _error = switch (e.code) {
            'unauthorized' => l10n.myFoodNeedAccount,
            'missing_gemini_key' || 'gemini_key' => l10n.coachErrNoKey,
            'daily_limit' => l10n.coachErrLimit,
            'gemini_quota' => l10n.coachErrQuota,
            'gemini_busy' => l10n.coachErrBusy,
            _ => l10n.coachErrGeneric,
          });
    } catch (_) {
      setState(() => _error = l10n.coachErrNetwork);
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final grams = _num(_grams);
    final kcal = _num(_kcal);
    if (_name.text.trim().isEmpty || grams <= 0) {
      setState(() => _error = l10n.myFoodNeedNameWeight);
      return;
    }
    if (kcal <= 0) {
      setState(() => _error = l10n.myFoodNeedValues);
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(nutritionRepositoryProvider);
    double per100(double v) => double.parse((v * 100 / grams).toStringAsFixed(2));
    final id = await repo.saveCustomFood(
      name: _name.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      category: 'custom',
      servingWeightG: grams,
      servingDescription: '${grams.toStringAsFixed(0)} g',
      caloriesPer100g: per100(kcal),
      proteinPer100g: per100(_num(_protein)),
      carbsPer100g: per100(_num(_carbs)),
      fatPer100g: per100(_num(_fat)),
      fiberPer100g: _fiber100 > 0 ? _fiber100 : null,
      prepState: 'prepared',
    );
    if (_logNow) {
      final food = await repo.getFoodById(id);
      final day = ref.read(selectedDateProvider);
      final now = DateTime.now();
      if (food != null) {
        await repo.logFood(
          food: food,
          quantityGrams: grams,
          mealType: _meal,
          timestamp: DateTime(day.year, day.month, day.day, now.hour, now.minute),
          isEaten: _eaten,
          eatenAt: DateTime(day.year, day.month, day.day, _time.hour, _time.minute),
        );
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_logNow ? l10n.myFoodSavedLogged : l10n.myFoodSaved)));
    if (_logNow) {
      context.go('/nutrition');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final signedIn = ref.watch(cloudServiceProvider).user != null;
    final e = _estimate;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.foodsAddMine)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.myFoodName, hintText: l10n.myFoodNameHint, prefixIcon: const Icon(Icons.restaurant_rounded)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _desc,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.myFoodDescription, hintText: l10n.myFoodDescriptionHint, alignLabelWithHint: true),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _grams,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: l10n.myFoodWeight, suffixText: l10n.commonGrams, prefixIcon: const Icon(Icons.scale_rounded)),
            onChanged: (_) => _rescale(),
          ),
          const SizedBox(height: 14),

          // ---------------- AI analysis ----------------
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.violet, foregroundColor: Colors.white),
              icon: _analyzing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(_analyzing ? l10n.myFoodAnalyzing : l10n.myFoodAnalyze),
              onPressed: _analyzing ? null : (signedIn ? _analyze : () => context.push('/settings/cloud')),
            ),
          ),
          if (!signedIn)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(l10n.myFoodNeedAccount, style: theme.textTheme.bodySmall),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          if (e != null) ...[
            const SizedBox(height: 12),
            AppCard(
              gradient: context.heroGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: AppColors.violet, size: 18),
                      const SizedBox(width: 6),
                      Expanded(child: Text(e.foodName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                      Pill(
                        label: switch (e.confidence) {
                          'high' => l10n.myFoodConfHigh,
                          'low' => l10n.myFoodConfLow,
                          _ => l10n.myFoodConfMedium,
                        },
                        color: switch (e.confidence) {
                          'high' => AppColors.success,
                          'low' => AppColors.flame,
                          _ => AppColors.carbs,
                        },
                      ),
                    ],
                  ),
                  if (e.assumptions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(e.assumptions, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.myFoodPer100}: ${e.kcal100.toStringAsFixed(0)} ${l10n.commonKcal} • P ${e.protein100} • C ${e.carbs100} • F ${e.fat100}',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],

          // ---------------- Values for this portion (editable) ----------------
          SectionHeader(title: l10n.myFoodPortionValues(_grams.text.isEmpty ? '0' : _grams.text)),
          Row(
            children: [
              Expanded(child: _MacroField(controller: _kcal, label: l10n.commonKcal, color: AppColors.lime)),
              const SizedBox(width: 8),
              Expanded(child: _MacroField(controller: _protein, label: l10n.dashboardProtein, color: AppColors.protein)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _MacroField(controller: _carbs, label: l10n.dashboardCarbs, color: AppColors.carbs)),
              const SizedBox(width: 8),
              Expanded(child: _MacroField(controller: _fat, label: l10n.dashboardFat, color: AppColors.fat)),
            ],
          ),
          const SizedBox(height: 6),
          Text(l10n.myFoodEditHint, style: theme.textTheme.bodySmall),

          // ---------------- Log it now? ----------------
          const SizedBox(height: 14),
          AppCard(
            padding: const EdgeInsets.fromLTRB(14, 4, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.myFoodLogNow, style: const TextStyle(fontWeight: FontWeight.w700)),
                  value: _logNow,
                  onChanged: (v) => setState(() => _logNow = v),
                ),
                if (_logNow)
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final m in [
                        ('breakfast', l10n.nutritionMealBreakfast),
                        ('lunch', l10n.nutritionMealLunch),
                        ('dinner', l10n.nutritionMealDinner),
                        ('snack', l10n.nutritionMealSnacks),
                      ])
                        ChoiceChip(label: Text(m.$2), selected: _meal == m.$1, onSelected: (_) => setState(() => _meal = m.$1)),
                    ],
                  ),
              ],
            ),
          ),
          if (_logNow) ...[
            const SizedBox(height: 10),
            EatenToggleCard(
              eaten: _eaten,
              time: _time,
              onEatenChanged: (v) => setState(() => _eaten = v),
              onTimeChanged: (t) => setState(() => _time = t),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded),
              label: Text(_logNow ? l10n.myFoodSaveAndLog : l10n.commonSave),
              onPressed: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color color;

  const _MacroField({required this.controller, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        ),
      ),
    );
  }
}
