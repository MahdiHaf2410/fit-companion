import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/energy_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'eaten_widgets.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  final String foodId;
  final String? initialMealType;

  const AddFoodScreen({
    super.key,
    required this.foodId,
    this.initialMealType,
  });

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _quantityController = TextEditingController(text: '100');
  late String _selectedMeal;
  Food? _food;
  bool _isLoading = true;
  // "Did you eat it?" — eaten now (default) or planned for later
  bool _eaten = true;
  TimeOfDay _eatenTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMealType ?? 'lunch';
    _loadFood();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadFood() async {
    final repo = ref.read(nutritionRepositoryProvider);
    final food = await repo.getFoodById(widget.foodId);
    if (mounted) {
      setState(() {
        _food = food;
        _isLoading = false;
        if (food != null && food.servingWeightG > 0) {
          _quantityController.text = food.servingWeightG.toInt().toString();
        }
      });
    }
  }

  Future<void> _logFood() async {
    if (_food == null) return;
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) return;

    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();
    // Combine selected date with current time
    final timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    await ref.read(nutritionRepositoryProvider).logFood(
      food: _food!,
      quantityGrams: quantity,
      mealType: _selectedMeal,
      timestamp: timestamp,
      isEaten: _eaten,
      eatenAt: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, _eatenTime.hour, _eatenTime.minute),
    );

    if (mounted) {
      context.go('/nutrition');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.nutritionLogFood)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_food == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.nutritionLogFood)),
        body: Center(child: Text(l10n.commonError)),
      );
    }

    final displayName = (isAr && _food!.nameAr != null && _food!.nameAr!.isNotEmpty)
        ? _food!.nameAr!
        : _food!.name;

    final currentQty = double.tryParse(_quantityController.text) ?? 0.0;
    final calculatedCals = EnergyCalculator.calculateNutrient(
      nutrientPer100g: _food!.caloriesPer100g,
      quantityGrams: currentQty,
    );
    final calculatedP = EnergyCalculator.calculateNutrient(
      nutrientPer100g: _food!.proteinPer100g,
      quantityGrams: currentQty,
    );
    final calculatedC = EnergyCalculator.calculateNutrient(
      nutrientPer100g: _food!.carbsPer100g,
      quantityGrams: currentQty,
    );
    final calculatedF = EnergyCalculator.calculateNutrient(
      nutrientPer100g: _food!.fatPer100g,
      quantityGrams: currentQty,
    );

    final meals = [
      {'id': 'breakfast', 'label': l10n.nutritionMealBreakfast},
      {'id': 'lunch', 'label': l10n.nutritionMealLunch},
      {'id': 'dinner', 'label': l10n.nutritionMealDinner},
      {'id': 'snack', 'label': l10n.nutritionMealSnacks},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Info Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_food!.servingDescription, style: theme.textTheme.bodyMedium),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _nutrientCol(l10n.dashboardCalories, "${calculatedCals.toInt()} kcal", theme.colorScheme.primary),
                      _nutrientCol(l10n.dashboardProtein, "${calculatedP}g", Colors.blue),
                      _nutrientCol(l10n.dashboardCarbs, "${calculatedC}g", Colors.orange),
                      _nutrientCol(l10n.dashboardFat, "${calculatedF}g", Colors.pink),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal Type Selector
            Text(l10n.nutritionSelectMeal, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: meals.map((m) {
                final isSelected = _selectedMeal == m['id'];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: ChoiceChip(
                      label: Text(m['label']!, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedMeal = m['id']!);
                        }
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Quantity Input
            Text(l10n.nutritionQuantity, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.scale_rounded),
                suffixText: l10n.commonGrams,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Quick Portion Chips
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: Text('50${l10n.commonGrams}'),
                  onPressed: () => setState(() => _quantityController.text = '50'),
                ),
                ActionChip(
                  label: Text('100${l10n.commonGrams}'),
                  onPressed: () => setState(() => _quantityController.text = '100'),
                ),
                ActionChip(
                  label: Text('150${l10n.commonGrams}'),
                  onPressed: () => setState(() => _quantityController.text = '150'),
                ),
                ActionChip(
                  label: Text('200${l10n.commonGrams}'),
                  onPressed: () => setState(() => _quantityController.text = '200'),
                ),
                if (_food!.servingWeightG > 0)
                  ActionChip(
                    label: Text('1 Serving (${_food!.servingWeightG.toInt()}${l10n.commonGrams})'),
                    onPressed: () => setState(() => _quantityController.text = _food!.servingWeightG.toInt().toString()),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Did you eat it? + when
            EatenToggleCard(
              eaten: _eaten,
              time: _eatenTime,
              onEatenChanged: (v) => setState(() => _eaten = v),
              onTimeChanged: (t) => setState(() => _eatenTime = t),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logFood,
                child: Text(l10n.nutritionSaveLog),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutrientCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }
}
