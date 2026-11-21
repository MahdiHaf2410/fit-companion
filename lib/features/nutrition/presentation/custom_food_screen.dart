import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/database_provider.dart';
import 'nutrition_providers.dart';
import '../../../l10n/app_localizations.dart';

class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _servingDescController = TextEditingController(text: '1 portion (100g)');
  final _servingWeightController = TextEditingController(text: '100');
  final _calsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();

  String _category = 'protein';
  final String _prepState = 'cooked';

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _servingDescController.dispose();
    _servingWeightController.dispose();
    _calsController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomFood() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(nutritionRepositoryProvider);
    final cals = double.parse(_calsController.text);
    final p = double.parse(_proteinController.text);
    final c = double.parse(_carbsController.text);
    final f = double.parse(_fatController.text);
    final fiber = double.tryParse(_fiberController.text);
    final servingWeight = double.tryParse(_servingWeightController.text) ?? 100.0;

    await repo.saveCustomFood(
      name: _nameController.text.trim(),
      nameAr: _nameArController.text.trim().isEmpty ? null : _nameArController.text.trim(),
      category: _category,
      servingWeightG: servingWeight,
      servingDescription: _servingDescController.text.trim(),
      caloriesPer100g: cals,
      proteinPer100g: p,
      carbsPer100g: c,
      fatPer100g: f,
      fiberPer100g: fiber,
      prepState: _prepState,
    );

    ref.invalidate(foodSearchResultsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom food saved successfully!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nutritionAddCustomFood),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.nutritionFoodName,
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameArController,
                decoration: InputDecoration(
                  labelText: l10n.nutritionFoodNameArabic,
                  prefixIcon: const Icon(Icons.language_rounded),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: l10n.nutritionCategories,
                  prefixIcon: const Icon(Icons.category_rounded),
                ),
                items: [
                  DropdownMenuItem(value: 'staples', child: Text(l10n.nutritionCategoryStaples)),
                  DropdownMenuItem(value: 'protein', child: Text(l10n.nutritionCategoryProtein)),
                  DropdownMenuItem(value: 'dairy', child: Text(l10n.nutritionCategoryDairy)),
                  DropdownMenuItem(value: 'produce', child: Text(l10n.nutritionCategoryProduce)),
                  DropdownMenuItem(value: 'algerian', child: Text(l10n.nutritionCategoryAlgerian)),
                  DropdownMenuItem(value: 'snacks', child: Text(l10n.nutritionCategorySnacks)),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _category = v);
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _servingDescController,
                      decoration: InputDecoration(labelText: l10n.nutritionServingSize),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _servingWeightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Grams', suffixText: 'g'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nutrients per 100g
              Text(
                'Nutritional Values (Per 100g basis)',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.nutritionCaloriesPer100g,
                  prefixIcon: const Icon(Icons.local_fire_department_rounded),
                  suffixText: l10n.commonKcal,
                ),
                validator: (v) => (double.tryParse(v ?? '') == null) ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.nutritionProteinPer100g, suffixText: 'g'),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.nutritionCarbsPer100g, suffixText: 'g'),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.nutritionFatPer100g, suffixText: 'g'),
                      validator: (v) => (double.tryParse(v ?? '') == null) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveCustomFood,
                  child: Text(l10n.commonSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
