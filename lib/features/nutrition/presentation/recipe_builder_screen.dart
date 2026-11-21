import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/energy_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class RecipeBuilderScreen extends ConsumerStatefulWidget {
  const RecipeBuilderScreen({super.key});

  @override
  ConsumerState<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends ConsumerState<RecipeBuilderScreen> {
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _servingsController = TextEditingController(text: '2');
  final _yieldController = TextEditingController();

  final List<Map<String, dynamic>> _ingredients = [];

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _servingsController.dispose();
    _yieldController.dispose();
    super.dispose();
  }

  void _addIngredient(Food food, double quantityGrams) {
    final calories = EnergyCalculator.calculateNutrient(nutrientPer100g: food.caloriesPer100g, quantityGrams: quantityGrams);
    final protein = EnergyCalculator.calculateNutrient(nutrientPer100g: food.proteinPer100g, quantityGrams: quantityGrams);
    final carbs = EnergyCalculator.calculateNutrient(nutrientPer100g: food.carbsPer100g, quantityGrams: quantityGrams);
    final fat = EnergyCalculator.calculateNutrient(nutrientPer100g: food.fatPer100g, quantityGrams: quantityGrams);

    setState(() {
      _ingredients.add({
        'foodId': food.id,
        'foodName': food.name,
        'quantityG': quantityGrams,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      });
    });
  }

  Future<void> _pickFoodModal() async {
    final repo = ref.read(nutritionRepositoryProvider);
    final allFoods = await repo.searchFoodsStream().first;

    if (!mounted) return;

    Food? selectedFood;
    double enteredGrams = 100.0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Select Ingredient',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollCtrl,
                          itemCount: allFoods.length,
                          separatorBuilder: (_, __) => const Divider(height: 8),
                          itemBuilder: (context, i) {
                            final f = allFoods[i];
                            final isSel = selectedFood?.id == f.id;
                            return ListTile(
                              title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text('${f.caloriesPer100g.toInt()} kcal / 100g'),
                              trailing: isSel ? const Icon(Icons.check_circle, color: Colors.green) : null,
                              onTap: () {
                                setModalState(() => selectedFood = f);
                              },
                            );
                          },
                        ),
                      ),
                      if (selectedFood != null) ...[
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: '100',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Quantity (grams)', suffixText: 'g'),
                                onChanged: (v) {
                                  enteredGrams = double.tryParse(v) ?? 100.0;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () {
                                _addIngredient(selectedFood!, enteredGrams);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
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

  Future<void> _saveRecipe() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name')),
      );
      return;
    }

    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    final servings = int.tryParse(_servingsController.text) ?? 1;
    final totalYield = double.tryParse(_yieldController.text);

    await ref.read(nutritionRepositoryProvider).saveRecipe(
      name: _nameController.text.trim(),
      nameAr: _nameArController.text.trim().isEmpty ? null : _nameArController.text.trim(),
      servings: servings > 0 ? servings : 1,
      totalCookedYieldG: totalYield,
      ingredients: _ingredients,
    );

    ref.invalidate(recipesStreamProvider);
    ref.invalidate(foodSearchResultsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    double totalCals = 0;
    double totalP = 0;
    double totalC = 0;
    double totalF = 0;

    for (final ing in _ingredients) {
      totalCals += ing['calories'] as double;
      totalP += ing['protein'] as double;
      totalC += ing['carbs'] as double;
      totalF += ing['fat'] as double;
    }

    final servings = int.tryParse(_servingsController.text) ?? 1;
    final safeServings = servings > 0 ? servings : 1;
    final perServingCal = (totalCals / safeServings).round();
    final perServingP = (totalP / safeServings).toStringAsFixed(1);
    final perServingC = (totalC / safeServings).toStringAsFixed(1);
    final perServingF = (totalF / safeServings).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipeTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.recipeName,
                prefixIcon: const Icon(Icons.receipt_long_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameArController,
              decoration: const InputDecoration(
                labelText: 'اسم الوصفة (عربي - اختياري)',
                prefixIcon: Icon(Icons.language_rounded),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.recipeServings,
                      prefixIcon: const Icon(Icons.people_outline_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _yieldController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Cooked Yield',
                      suffixText: l10n.commonGrams,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.recipeYieldHelp,
              style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),

            // Nutrition Summary Card
            AppCard(
              backgroundColor: theme.colorScheme.primary.withAlpha(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Recipe: ${totalCals.toInt()} kcal',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.recipePerServing(perServingCal, perServingP, perServingC, perServingF),
                    style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Ingredients Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.recipeIngredients,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.recipeAddIngredient),
                  onPressed: _pickFoodModal,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('No ingredients added yet. Tap "${l10n.recipeAddIngredient}" to select foods.'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ingredients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final ing = _ingredients[i];
                  return AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ing['foodName'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                "${(ing['quantityG'] as num).toInt()}g • ${(ing['calories'] as num).toInt()} kcal (P: ${ing['protein']}g, C: ${ing['carbs']}g, F: ${ing['fat']}g)",
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey),
                          onPressed: () {
                            setState(() => _ingredients.removeAt(i));
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(l10n.recipeSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
