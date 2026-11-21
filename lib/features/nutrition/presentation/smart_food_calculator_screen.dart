import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/energy_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class SmartFoodCalculatorScreen extends ConsumerStatefulWidget {
  final String? initialFoodId;
  final String? initialMealType;

  const SmartFoodCalculatorScreen({
    super.key,
    this.initialFoodId,
    this.initialMealType,
  });

  @override
  ConsumerState<SmartFoodCalculatorScreen> createState() => _SmartFoodCalculatorScreenState();
}

class _SmartFoodCalculatorScreenState extends ConsumerState<SmartFoodCalculatorScreen> {
  final _quantityController = TextEditingController(text: '150');
  late String _selectedMeal;
  Food? _selectedFood;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMealType ?? 'lunch';
    _initFood();
  }

  Future<void> _initFood() async {
    final repo = ref.read(nutritionRepositoryProvider);
    if (widget.initialFoodId != null && widget.initialFoodId!.isNotEmpty) {
      final food = await repo.getFoodById(widget.initialFoodId!);
      if (food != null) {
        setState(() {
          _selectedFood = food;
          _quantityController.text = food.servingWeightG > 0 ? food.servingWeightG.toInt().toString() : '100';
          _isLoading = false;
        });
        return;
      }
    }

    // Default to the first food in the library
    final foods = await repo.searchFoodsStream().first;
    if (mounted) {
      setState(() {
        if (foods.isNotEmpty) {
          _selectedFood = foods.first;
          _quantityController.text = _selectedFood!.servingWeightG > 0 ? _selectedFood!.servingWeightG.toInt().toString() : '100';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickFoodModal() async {
    final repo = ref.read(nutritionRepositoryProvider);
    final allFoods = await repo.searchFoodsStream().first;

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = allFoods.where((f) {
              if (query.isEmpty) return true;
              return f.name.toLowerCase().contains(query.toLowerCase()) ||
                  (f.nameAr != null && f.nameAr!.toLowerCase().contains(query.toLowerCase()));
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.9,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Select Food Reference',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search food or Algerian dish...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (val) {
                          setModalState(() => query = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollCtrl,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 6),
                          itemBuilder: (context, i) {
                            final f = filtered[i];
                            return ListTile(
                              title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                "${f.caloriesPer100g.toInt()} kcal / 100g • ${f.prepState} • ${f.source}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              onTap: () {
                                setState(() {
                                  _selectedFood = f;
                                  if (f.servingWeightG > 0) {
                                    _quantityController.text = f.servingWeightG.toInt().toString();
                                  }
                                });
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _logCalculatedFood() async {
    if (_selectedFood == null) return;
    final qty = double.tryParse(_quantityController.text);
    if (qty == null || qty <= 0) return;

    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();
    final timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );

    await ref.read(nutritionRepositoryProvider).logFood(
      food: _selectedFood!,
      quantityGrams: qty,
      mealType: _selectedMeal,
      timestamp: timestamp,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food logged successfully!')),
      );
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
        appBar: AppBar(title: Text(l10n.foodCalculatorTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final food = _selectedFood;
    if (food == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.foodCalculatorTitle)),
        body: Center(
          child: ElevatedButton(
            onPressed: _pickFoodModal,
            child: const Text('Pick Food'),
          ),
        ),
      );
    }

    final displayName = (isAr && food.nameAr != null && food.nameAr!.isNotEmpty)
        ? food.nameAr!
        : food.name;

    final currentQty = double.tryParse(_quantityController.text) ?? 100.0;
    final calculatedCals = EnergyCalculator.calculateNutrient(nutrientPer100g: food.caloriesPer100g, quantityGrams: currentQty);
    final calculatedP = EnergyCalculator.calculateNutrient(nutrientPer100g: food.proteinPer100g, quantityGrams: currentQty);
    final calculatedC = EnergyCalculator.calculateNutrient(nutrientPer100g: food.carbsPer100g, quantityGrams: currentQty);
    final calculatedF = EnergyCalculator.calculateNutrient(nutrientPer100g: food.fatPer100g, quantityGrams: currentQty);
    final calculatedFiber = food.fiberPer100g != null
        ? EnergyCalculator.calculateNutrient(nutrientPer100g: food.fiberPer100g!, quantityGrams: currentQty)
        : null;

    final meals = [
      {'id': 'breakfast', 'label': l10n.nutritionMealBreakfast},
      {'id': 'lunch', 'label': l10n.nutritionMealLunch},
      {'id': 'dinner', 'label': l10n.nutritionMealDinner},
      {'id': 'snack', 'label': l10n.nutritionMealSnacks},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.foodCalculatorTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.foodCalculatorSubtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Food Reference Card with Switch button
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                        label: const Text('Change'),
                        onPressed: _pickFoodModal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metadata Badges (Prep state, Source, Category)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _badge(
                        label: food.prepState.toUpperCase(),
                        color: Colors.teal,
                      ),
                      _badge(
                        label: food.source == 'verified' ? 'VERIFIED DATA' : 'RECIPE ESTIMATE',
                        color: food.source == 'verified' ? Colors.green : Colors.amber.shade800,
                      ),
                      if (food.category == 'algerian')
                        _badge(
                          label: isAr ? 'طبق جزائري' : 'ALGERIAN DISH',
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Standard reference: ${food.servingDescription} (${food.servingWeightG.toInt()}g)",
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interactive Portion / Quantity Section
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nutritionQuantity,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.scale_rounded),
                            suffixText: l10n.commonGrams,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Portion Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
                      ActionChip(
                        label: Text('300${l10n.commonGrams}'),
                        onPressed: () => setState(() => _quantityController.text = '300'),
                      ),
                      if (food.servingWeightG > 0)
                        ActionChip(
                          avatar: const Icon(Icons.restaurant_menu_rounded, size: 16),
                          label: Text('1 Serving (${food.servingWeightG.toInt()}${l10n.commonGrams})'),
                          onPressed: () => setState(() => _quantityController.text = food.servingWeightG.toInt().toString()),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calculated Results Card
            AppCard(
              backgroundColor: theme.colorScheme.primary.withAlpha(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Energy for ${currentQty.toInt()}g',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${calculatedCals.toInt()} ${l10n.commonKcal}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroCol(l10n.dashboardProtein, "${calculatedP}g", AppColors.protein),
                      _macroCol(l10n.dashboardCarbs, "${calculatedC}g", AppColors.carbs),
                      _macroCol(l10n.dashboardFat, "${calculatedF}g", AppColors.fat),
                      if (calculatedFiber != null)
                        _macroCol('Fiber', "${calculatedFiber}g", Colors.purple),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Calculation Transparency & Explanation Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate_outlined, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Calculation Breakdown (Per 100g basis)',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.foodCalculatorFormulaHelp,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Divider(height: 16),
                  _calcStep(
                    l10n.dashboardCalories,
                    "${food.caloriesPer100g.toInt()} kcal",
                    currentQty,
                    "${calculatedCals.toInt()} kcal",
                  ),
                  _calcStep(
                    l10n.dashboardProtein,
                    "${food.proteinPer100g}g",
                    currentQty,
                    "${calculatedP}g",
                  ),
                  _calcStep(
                    l10n.dashboardCarbs,
                    "${food.carbsPer100g}g",
                    currentQty,
                    "${calculatedC}g",
                  ),
                  _calcStep(
                    l10n.dashboardFat,
                    "${food.fatPer100g}g",
                    currentQty,
                    "${calculatedF}g",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal Type Selector
            Text(l10n.nutritionSelectMeal, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
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
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_task_rounded),
                label: Text(l10n.foodCalculatorAddToMeal),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _logCalculatedFood,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _badge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _macroCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
      ],
    );
  }

  Widget _calcStep(String nutrient, String basis, double grams, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: const TextStyle(fontSize: 13)),
          Text(
            "($basis × ${grams.toInt()}g) ÷ 100 = $result",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
