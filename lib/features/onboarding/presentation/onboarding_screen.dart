import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

import '../../../core/database/app_database.dart';
import '../../../core/utils/energy_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController(text: '25');
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '75');

  Sex _selectedSex = Sex.male;
  ActivityLevel _selectedActivity = ActivityLevel.moderatelyActive;
  FitnessGoal _selectedGoal = FitnessGoal.muscleGain;
  final int _trainingFrequency = 4;
  final String _preferredUnits = 'metric';

  MacroTargets? _calculatedTargets;

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _recalculate() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 175.0;
    final weight = double.tryParse(_weightController.text) ?? 75.0;

    if (age > 0 && height > 0 && weight > 0) {
      setState(() {
        _calculatedTargets = EnergyCalculator.calculateTarget(
          weightKg: weight,
          heightCm: height,
          age: age,
          sex: _selectedSex,
          activityLevel: _selectedActivity,
          goal: _selectedGoal,
        );
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;
    if (_calculatedTargets == null) _recalculate();

    final profileRepo = ref.read(profileRepositoryProvider);
    final age = int.parse(_ageController.text);
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);
    final currentLocale = ref.read(localeProvider);
    final currentTheme = ref.read(themeModeProvider);

    final profileId = const Uuid().v4();
    final goalId = const Uuid().v4();
    final now = DateTime.now();

    final profileComp = ProfilesCompanion.insert(
      id: profileId,
      displayName: drift.Value(_nameController.text.trim().isEmpty ? null : _nameController.text.trim()),
      age: age,
      sex: _selectedSex.name,
      heightCm: height,
      currentWeightKg: weight,
      activityLevel: _selectedActivity.name,
      trainingFrequency: drift.Value(_trainingFrequency),
      preferredUnits: drift.Value(_preferredUnits),
      preferredLanguage: drift.Value(currentLocale.languageCode),
      preferredTheme: drift.Value(currentTheme.name),
      isOnboarded: const drift.Value(true),
      updatedAt: now,
    );

    final goalComp = GoalsCompanion.insert(
      id: goalId,
      profileId: profileId,
      goalType: _selectedGoal.name,
      targetCalories: _calculatedTargets!.calories,
      targetProteinGrams: _calculatedTargets!.proteinGrams,
      targetCarbsGrams: _calculatedTargets!.carbsGrams,
      targetFatGrams: _calculatedTargets!.fatGrams,
      calculatedBmr: _calculatedTargets!.bmr,
      calculatedTdee: _calculatedTargets!.tdee,
      updatedAt: now,
    );

    await profileRepo.saveProfileAndGoal(profile: profileComp, goal: goalComp);

    // Also log initial weight into body metrics
    final progressRepo = ref.read(progressRepositoryProvider);
    await progressRepo.logMetric(weightKg: weight, notes: 'Starting weight');

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.profileLanguage,
            icon: const Icon(Icons.language_rounded),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLanguage();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onboardingTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.onboardingSubtitle,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Personal Info Inputs
                Text(l10n.profilePersonalInfo, style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.onboardingName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingAge,
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        validator: (v) {
                          final val = int.tryParse(v ?? '');
                          if (val == null || val < 12 || val > 120) return 'Invalid age';
                          return null;
                        },
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<Sex>(
                        initialValue: _selectedSex,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingSex,
                          prefixIcon: const Icon(Icons.wc_outlined),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: Sex.male,
                            child: Text(l10n.onboardingSexMale),
                          ),
                          DropdownMenuItem(
                            value: Sex.female,
                            child: Text(l10n.onboardingSexFemale),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _selectedSex = v);
                            _recalculate();
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
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingHeight,
                          prefixIcon: const Icon(Icons.height_outlined),
                        ),
                        validator: (v) {
                          final val = double.tryParse(v ?? '');
                          if (val == null || val < 80 || val > 260) return 'Invalid height';
                          return null;
                        },
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.onboardingWeight,
                          prefixIcon: const Icon(Icons.monitor_weight_outlined),
                        ),
                        validator: (v) {
                          final val = double.tryParse(v ?? '');
                          if (val == null || val < 30 || val > 300) return 'Invalid weight';
                          return null;
                        },
                        onChanged: (_) => _recalculate(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Activity Level
                Text(l10n.onboardingActivity, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<ActivityLevel>(
                  initialValue: _selectedActivity,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.directions_run_outlined),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: ActivityLevel.sedentary,
                      child: Text(l10n.onboardingActivitySedentary, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: ActivityLevel.lightlyActive,
                      child: Text(l10n.onboardingActivityLight, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: ActivityLevel.moderatelyActive,
                      child: Text(l10n.onboardingActivityModerate, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: ActivityLevel.veryActive,
                      child: Text(l10n.onboardingActivityVery, overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: ActivityLevel.extraActive,
                      child: Text(l10n.onboardingActivityExtra, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedActivity = v);
                      _recalculate();
                    }
                  },
                ),
                const SizedBox(height: 20),

                // Goal Selection
                Text(l10n.onboardingGoal, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<FitnessGoal>(
                  initialValue: _selectedGoal,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.track_changes_outlined),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: FitnessGoal.muscleGain,
                      child: Text(l10n.onboardingGoalMuscleGain),
                    ),
                    DropdownMenuItem(
                      value: FitnessGoal.fatLoss,
                      child: Text(l10n.onboardingGoalFatLoss),
                    ),
                    DropdownMenuItem(
                      value: FitnessGoal.maintenance,
                      child: Text(l10n.onboardingGoalMaintenance),
                    ),
                    DropdownMenuItem(
                      value: FitnessGoal.recomposition,
                      child: Text(l10n.onboardingGoalRecomp),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedGoal = v);
                      _recalculate();
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Calculated Target Card
                if (_calculatedTargets != null) ...[
                  AppCard(
                    backgroundColor: theme.colorScheme.primaryContainer.withAlpha(50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.onboardingTargetSummary,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.dashboardCalories, style: theme.textTheme.bodyLarge),
                            Text(
                              "${_calculatedTargets!.calories} ${l10n.commonKcal}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _macroBadge(l10n.dashboardProtein, "${_calculatedTargets!.proteinGrams}g", Colors.blue),
                            _macroBadge(l10n.dashboardCarbs, "${_calculatedTargets!.carbsGrams}g", Colors.orange),
                            _macroBadge(l10n.dashboardFat, "${_calculatedTargets!.fatGrams}g", Colors.pink),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.onboardingDisclaimer,
                          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    child: Text(l10n.onboardingGetStarted),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _macroBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
