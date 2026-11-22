import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';

class MealTemplateWithItems {
  final MealTemplate template;
  final List<MealTemplateItem> items;

  MealTemplateWithItems(this.template, this.items);

  double get calories => items.fold(0, (a, i) => a + i.calories);
  double get protein => items.fold(0, (a, i) => a + i.protein);
}

/// Copy-day, meal templates and barcode-food helpers.
class MealToolsRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  MealToolsRepository(this._db);

  // ---------------------------------------------------------------------------
  // Copying logs
  // ---------------------------------------------------------------------------

  /// Copies the logs of [fromDate] (optionally one [mealType]) into [toDate].
  /// Returns how many entries were copied.
  Future<int> copyLogs({required String fromDate, required String toDate, String? mealType}) async {
    final q = _db.select(_db.foodLogs)..where((l) => l.date.equals(fromDate));
    if (mealType != null) q.where((l) => l.mealType.equals(mealType));
    final logs = await q.get();
    final ts = _timestampFor(toDate);
    await _db.batch((b) {
      for (final l in logs) {
        b.insert(
          _db.foodLogs,
          // Copied food is a plan for that day: tick it when you actually eat it.
          l.copyWith(id: _uuid.v4(), date: toDate, timestamp: ts, isEaten: false, eatenAt: const Value(null)).toCompanion(true),
        );
      }
    });
    return logs.length;
  }

  DateTime _timestampFor(String date) {
    final parts = date.split('-').map(int.parse).toList();
    final now = DateTime.now();
    return DateTime(parts[0], parts[1], parts[2], now.hour, now.minute);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  Stream<List<MealTemplateWithItems>> watchTemplates() {
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.mealTemplates, _db.mealTemplateItems})
        .watch()
        .asyncMap((_) async {
      final templates = await (_db.select(_db.mealTemplates)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
      final items = await _db.select(_db.mealTemplateItems).get();
      return templates
          .map((t) => MealTemplateWithItems(t, items.where((i) => i.templateId == t.id).toList()))
          .toList();
    });
  }

  /// Saves the logs of a meal on [date] as a reusable template.
  Future<bool> saveMealAsTemplate({required String date, required String mealType, required String name}) async {
    final logs = await (_db.select(_db.foodLogs)
          ..where((l) => l.date.equals(date) & l.mealType.equals(mealType)))
        .get();
    if (logs.isEmpty) return false;
    final id = _uuid.v4();
    await _db.transaction(() async {
      await _db.into(_db.mealTemplates).insert(MealTemplatesCompanion.insert(
            id: id,
            name: name,
            mealType: Value(mealType),
            createdAt: DateTime.now(),
          ));
      for (final l in logs) {
        await _db.into(_db.mealTemplateItems).insert(MealTemplateItemsCompanion.insert(
              id: _uuid.v4(),
              templateId: id,
              foodId: Value(l.foodId),
              foodName: l.foodName,
              foodNameAr: Value(l.foodNameAr),
              quantityG: l.quantityG,
              calories: l.calories,
              protein: l.protein,
              carbs: l.carbs,
              fat: l.fat,
            ));
      }
    });
    return true;
  }

  Future<void> applyTemplate({required String templateId, required String date, required String mealType}) async {
    final items = await (_db.select(_db.mealTemplateItems)..where((i) => i.templateId.equals(templateId))).get();
    final ts = _timestampFor(date);
    await _db.batch((b) {
      for (final i in items) {
        b.insert(
          _db.foodLogs,
          FoodLogsCompanion.insert(
            id: _uuid.v4(),
            foodId: Value(i.foodId),
            date: date,
            timestamp: ts,
            mealType: mealType,
            quantityG: i.quantityG,
            foodName: i.foodName,
            foodNameAr: Value(i.foodNameAr),
            calories: i.calories,
            protein: i.protein,
            carbs: i.carbs,
            fat: i.fat,
            isEaten: const Value(false),
          ),
        );
      }
    });
  }

  Future<void> deleteTemplate(String id) async {
    await (_db.delete(_db.mealTemplateItems)..where((i) => i.templateId.equals(id))).go();
    await (_db.delete(_db.mealTemplates)..where((t) => t.id.equals(id))).go();
  }

  // ---------------------------------------------------------------------------
  // Barcode foods
  // ---------------------------------------------------------------------------

  Future<Food?> findByBarcode(String barcode) {
    return (_db.select(_db.foods)..where((f) => f.barcode.equals(barcode))..limit(1)).getSingleOrNull();
  }

  /// Stores a product fetched online so it works offline next time.
  Future<Food> saveScannedFood({
    required String barcode,
    required String name,
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatPer100g,
    double? fiberPer100g,
    double servingWeightG = 100,
    String servingDescription = '100 g',
  }) async {
    final now = DateTime.now();
    final id = 'bc_$barcode';
    final companion = FoodsCompanion.insert(
      id: id,
      name: name,
      category: 'snacks',
      source: 'estimated',
      servingDescription: servingDescription,
      servingWeightG: servingWeightG,
      caloriesPer100g: caloriesPer100g,
      proteinPer100g: proteinPer100g,
      carbsPer100g: carbsPer100g,
      fatPer100g: fatPer100g,
      fiberPer100g: Value(fiberPer100g),
      prepState: const Value('prepared'),
      isCustom: const Value(true),
      barcode: Value(barcode),
      createdAt: now,
      updatedAt: now,
    );
    await _db.into(_db.foods).insertOnConflictUpdate(companion);
    return (await (_db.select(_db.foods)..where((f) => f.id.equals(id))).getSingle());
  }
}
