import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/energy_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../profile/presentation/profile_providers.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class NutritionCalculatorScreen extends ConsumerStatefulWidget {
  const NutritionCalculatorScreen({super.key});

  @override
  ConsumerState<NutritionCalculatorScreen> createState() => _NutritionCalculatorScreenState();
}

class _NutritionCalculatorScreenState extends ConsumerState<NutritionCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '75');

  Sex _selectedSex = Sex.male;
  ActivityLevel _selectedActivity = ActivityLevel.moderatelyActive;
  TrainingType _selectedTrainingType = TrainingType.strengthHypertrophy;
  FitnessGoal _selectedGoal = FitnessGoal.muscleGain;
  int _trainingFrequency = 4;

  MacroTargets? _recommendedTargets;

  // Manual Adjustments
  int _manualCalories = 2500;
  double _manualProtein = 150.0;
  double _manualCarbs = 280.0;
  double _manualFat = 70.0;
  bool _isManualMode = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    final goal = await ref.read(profileRepositoryProvider).getGoal();

    if (profile != null) {
      _ageController.text = profile.age.toString();
      _heightController.text = profile.heightCm.toInt().toString();
      _weightController.text = profile.currentWeightKg.toStringAsFixed(1);
      _selectedSex = profile.sex == 'female' ? Sex.female : Sex.male;
      _trainingFrequency = profile.trainingFrequency ?? 4;
      try {
        _selectedActivity = ActivityLevel.values.byName(profile.activityLevel);
      } catch (_) {}
    }

    if (goal != null) {
      try {
        _selectedGoal = FitnessGoal.values.byName(goal.goalType);
      } catch (_) {}
    }

    _calculateRecommended();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateRecommended() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final weight = double.tryParse(_weightController.text) ?? 75.0;

    if (age > 0 && height > 0 && weight > 0) {
      final targets = EnergyCalculator.calculateTarget(
        weightKg: weight,
        heightCm: height,
        age: age,
        sex: _selectedSex,
        activityLevel: _selectedActivity,
        goal: _selectedGoal,
        trainingType: _selectedTrainingType,
      );

      setState(() {
        _recommendedTargets = targets;
        if (!_isManualMode) {
          _manualCalories = targets.calories;
          _manualProtein = targets.proteinGrams;
          _manualCarbs = targets.carbsGrams;
          _manualFat = targets.fatGrams;
        }
      });
    }
  }

  void _restoreRecommended() {
    if (_recommendedTargets == null) return;
    setState(() {
      _isManualMode = false;
      _manualCalories = _recommendedTargets!.calories;
      _manualProtein = _recommendedTargets!.proteinGrams;
      _manualCarbs = _recommendedTargets!.carbsGrams;
      _manualFat = _recommendedTargets!.fatGrams;
    });
  }

  Future<void> _applyTargets() async {
    final l10n = AppLocalizations.of(context)!;
    if (_recommendedTargets == null) return;

    final isConsistent = EnergyCalculator.isMacroSumConsistent(
      calories: _manualCalories,
      proteinG: _manualProtein,
      carbsG: _manualCarbs,
      fatG: _manualFat,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nutritionCalculatorApply),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.nutritionCalculatorConfirm),
            const SizedBox(height: 12),
            Text(
              "• ${l10n.dashboardCalories}: $_manualCalories ${l10n.commonKcal}\n"
              "• ${l10n.dashboardProtein}: ${_manualProtein.toStringAsFixed(0)}g\n"
              "• ${l10n.dashboardCarbs}: ${_manualCarbs.toStringAsFixed(0)}g\n"
              "• ${l10n.dashboardFat}: ${_manualFat.toStringAsFixed(0)}g",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (!isConsistent) ...[
              const SizedBox(height: 12),
              Text(
                l10n.nutritionCalculatorMacroWarning,
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonConfirm)),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = ref.read(profileRepositoryProvider);
      final profile = await repo.getProfile();
      final goal = await repo.getGoal();

      final age = int.parse(_ageController.text);
      final height = double.parse(_heightController.text);
      final weight = double.parse(_weightController.text);

      if (profile != null) {
        await repo.saveProfileAndGoal(
          profile: ProfilesCompanion(
            id: drift.Value(profile.id),
            displayName: drift.Value(profile.displayName),
            age: drift.Value(age),
            sex: drift.Value(_selectedSex.name),
            heightCm: drift.Value(height),
            currentWeightKg: drift.Value(weight),
            activityLevel: drift.Value(_selectedActivity.name),
            trainingFrequency: drift.Value(_trainingFrequency),
            preferredUnits: drift.Value(profile.preferredUnits),
            preferredLanguage: drift.Value(profile.preferredLanguage),
            preferredTheme: drift.Value(profile.preferredTheme),
            isOnboarded: const drift.Value(true),
            updatedAt: drift.Value(DateTime.now()),
          ),
          goal: GoalsCompanion(
            id: drift.Value(goal?.id ?? 'goal_1'),
            profileId: drift.Value(profile.id),
            goalType: drift.Value(_selectedGoal.name),
            targetCalories: drift.Value(_manualCalories),
            targetProteinGrams: drift.Value(_manualProtein),
            targetCarbsGrams: drift.Value(_manualCarbs),
            targetFatGrams: drift.Value(_manualFat),
            calculatedBmr: drift.Value(_recommendedTargets!.bmr),
            calculatedTdee: drift.Value(_recommendedTargets!.tdee),
            updatedAt: drift.Value(DateTime.now()),
          ),
        );
      }

      ref.invalidate(profileStreamProvider);
      ref.invalidate(goalStreamProvider);
      ref.invalidate(dailyNutritionSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.commonSuccess)),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isConsistent = EnergyCalculator.isMacroSumConsistent(
      calories: _manualCalories,
      proteinG: _manualProtein,
      carbsG: _manualCarbs,
      fatG: _manualFat,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionCalculatorTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nutritionCalculatorDesc,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Inputs Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.profilePersonalInfo, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: l10n.onboardingAge, prefixIcon: const Icon(Icons.cake_outlined)),
                            onChanged: (_) => _calculateRecommended(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<Sex>(
                            initialValue: _selectedSex,
                            decoration: InputDecoration(labelText: l10n.onboardingSex, prefixIcon: const Icon(Icons.wc_outlined)),
                            items: [
                              DropdownMenuItem(value: Sex.male, child: Text(l10n.onboardingSexMale)),
                              DropdownMenuItem(value: Sex.female, child: Text(l10n.onboardingSexFemale)),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedSex = v);
                                _calculateRecommended();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.onboardingHeight, suffixText: 'cm'),
                            onChanged: (_) => _calculateRecommended(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.onboardingWeight, suffixText: 'kg'),
                            onChanged: (_) => _calculateRecommended(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Activity Level
                    Text(l10n.onboardingActivity, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<ActivityLevel>(
                      initialValue: _selectedActivity,
                      isExpanded: true,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.directions_run_rounded)),
                      items: [
                        DropdownMenuItem(value: ActivityLevel.sedentary, child: Text(l10n.onboardingActivitySedentary, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: ActivityLevel.lightlyActive, child: Text(l10n.onboardingActivityLight, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: ActivityLevel.moderatelyActive, child: Text(l10n.onboardingActivityModerate, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: ActivityLevel.veryActive, child: Text(l10n.onboardingActivityVery, overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: ActivityLevel.extraActive, child: Text(l10n.onboardingActivityExtra, overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedActivity = v);
                          _calculateRecommended();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Training Style & Goal
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TrainingType>(
                            initialValue: _selectedTrainingType,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: l10n.nutritionTrainingType),
                            items: [
                              DropdownMenuItem(value: TrainingType.strengthHypertrophy, child: Text(l10n.nutritionTrainingStrength, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: TrainingType.cardioEndurance, child: Text(l10n.nutritionTrainingCardio, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: TrainingType.functionalHybrid, child: Text(l10n.nutritionTrainingHybrid, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: TrainingType.generalFitness, child: Text(l10n.nutritionTrainingGeneral, overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedTrainingType = v);
                                _calculateRecommended();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<FitnessGoal>(
                            initialValue: _selectedGoal,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: l10n.onboardingGoal),
                            items: [
                              DropdownMenuItem(value: FitnessGoal.muscleGain, child: Text(l10n.onboardingGoalMuscleGain, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: FitnessGoal.fatLoss, child: Text(l10n.onboardingGoalFatLoss, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: FitnessGoal.maintenance, child: Text(l10n.onboardingGoalMaintenance, overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: FitnessGoal.recomposition, child: Text(l10n.onboardingGoalRecomp, overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedGoal = v);
                                _calculateRecommended();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Results Overview Cards
              if (_recommendedTargets != null) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.nutritionCalculatorBmr, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "${_recommendedTargets!.bmr.toInt()} ${l10n.commonKcal}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.nutritionCalculatorBmrDesc, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.nutritionCalculatorTdee, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "${_recommendedTargets!.tdee.toInt()} ${l10n.commonKcal}",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
                            ),
                            const SizedBox(height: 4),
                            Text(l10n.nutritionCalculatorTdeeDesc, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recommended Target Card
                AppCard(
                  backgroundColor: theme.colorScheme.primary.withAlpha(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.nutritionCalculatorTarget,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "$_manualCalories ${l10n.commonKcal}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _macroBadge(l10n.dashboardProtein, "${_manualProtein.toInt()}g", AppColors.protein),
                          _macroBadge(l10n.dashboardCarbs, "${_manualCarbs.toInt()}g", AppColors.carbs),
                          _macroBadge(l10n.dashboardFat, "${_manualFat.toInt()}g", AppColors.fat),
                        ],
                      ),
                      if (!isConsistent) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                l10n.nutritionCalculatorMacroWarning,
                                style: const TextStyle(color: Colors.orange, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Expandable "How was this calculated?" section
                AppCard(
                  padding: EdgeInsets.zero,
                  child: ExpansionTile(
                    title: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.nutritionCalculatorHow,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      const Divider(),
                      _explanationRow('1. BMR', _recommendedTargets!.breakdown?.bmrFormulaExplanation ?? ''),
                      const SizedBox(height: 8),
                      _explanationRow('2. TDEE', _recommendedTargets!.breakdown?.activityExplanation ?? ''),
                      const SizedBox(height: 8),
                      _explanationRow('3. Goal Strategy', _recommendedTargets!.breakdown?.goalAdjustmentExplanation ?? ''),
                      const SizedBox(height: 8),
                      _explanationRow('4. Protein', _recommendedTargets!.breakdown?.proteinLogicExplanation ?? ''),
                      const SizedBox(height: 8),
                      _explanationRow('5. Dietary Fat', _recommendedTargets!.breakdown?.fatLogicExplanation ?? ''),
                      const SizedBox(height: 8),
                      _explanationRow('6. Carbohydrates', _recommendedTargets!.breakdown?.carbsLogicExplanation ?? ''),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Manual Adjustments Section
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.nutritionCalculatorManualAdjust,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (_isManualMode)
                            TextButton.icon(
                              icon: const Icon(Icons.restore_rounded, size: 16),
                              label: Text(l10n.nutritionCalculatorReset, style: const TextStyle(fontSize: 12)),
                              onPressed: _restoreRecommended,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text("${l10n.dashboardCalories}: $_manualCalories ${l10n.commonKcal}"),
                      Slider(
                        value: _manualCalories.toDouble().clamp(1200.0, 4500.0),
                        min: 1200.0,
                        max: 4500.0,
                        divisions: 66,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _isManualMode = true;
                            _manualCalories = val.round();
                          });
                        },
                      ),

                      Text("${l10n.dashboardProtein}: ${_manualProtein.round()}g (4 kcal/g)"),
                      Slider(
                        value: _manualProtein.clamp(40.0, 300.0),
                        min: 40.0,
                        max: 300.0,
                        divisions: 52,
                        activeColor: AppColors.protein,
                        onChanged: (val) {
                          setState(() {
                            _isManualMode = true;
                            _manualProtein = val.roundToDouble();
                          });
                        },
                      ),

                      Text("${l10n.dashboardCarbs}: ${_manualCarbs.round()}g (4 kcal/g)"),
                      Slider(
                        value: _manualCarbs.clamp(30.0, 500.0),
                        min: 30.0,
                        max: 500.0,
                        divisions: 94,
                        activeColor: AppColors.carbs,
                        onChanged: (val) {
                          setState(() {
                            _isManualMode = true;
                            _manualCarbs = val.roundToDouble();
                          });
                        },
                      ),

                      Text("${l10n.dashboardFat}: ${_manualFat.round()}g (9 kcal/g)"),
                      Slider(
                        value: _manualFat.clamp(20.0, 180.0),
                        min: 20.0,
                        max: 180.0,
                        divisions: 32,
                        activeColor: AppColors.fat,
                        onChanged: (val) {
                          setState(() {
                            _isManualMode = true;
                            _manualFat = val.roundToDouble();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_rounded),
                    label: Text(l10n.nutritionCalculatorApply),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _applyTargets,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
        ),
      ],
    );
  }

  Widget _explanationRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title: ",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        Expanded(
          child: Text(
            desc,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
