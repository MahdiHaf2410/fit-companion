import 'dart:convert';

import 'package:http/http.dart' as http;

/// Minimal nutrition data for one product from Open Food Facts.
class OffProduct {
  final String barcode;
  final String name;
  final String? brand;
  // Null when Open Food Facts has the product but not its nutrition table.
  final double? kcal, protein, carbs, fat;
  final double? fiber;
  final double? servingG;

  const OffProduct({
    required this.barcode,
    required this.name,
    this.brand,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.servingG,
  });

  /// True when calories and the three macros are known.
  bool get complete => kcal != null && protein != null && carbs != null && fat != null;

  /// Parses an Open Food Facts v2 product response. Returns null only when the
  /// product is unknown. Missing nutrition values stay null (AI fills them later).
  static OffProduct? fromResponse(String barcode, Map<String, dynamic> json) {
    if (json['status'] != 1 && json['status'] != 'success' && json['product'] == null) return null;
    final p = json['product'] as Map<String, dynamic>?;
    if (p == null) return null;
    final n = (p['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
    double? read(String k) {
      final v = n[k];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v.replaceAll(',', '.'));
      return null;
    }

    var kcal = read('energy-kcal_100g');
    final kj = read('energy_100g') ?? read('energy-kj_100g');
    if (kcal == null && kj != null) kcal = kj / 4.184;
    final protein = read('proteins_100g');
    final carbs = read('carbohydrates_100g');
    final fat = read('fat_100g');
    // Only kcal + some macros known: treat missing macros as 0 (common for drinks).
    final anyMacro = protein != null || carbs != null || fat != null;

    final name = [p['product_name_ar'], p['product_name_fr'], p['product_name'], p['product_name_en']]
        .whereType<String>()
        .firstWhere((s) => s.trim().isNotEmpty, orElse: () => barcode);
    final brand = (p['brands'] as String?)?.split(',').first.trim();
    final serving = (p['serving_quantity'] is num) ? (p['serving_quantity'] as num).toDouble() : null;

    return OffProduct(
      barcode: barcode,
      name: brand != null && brand.isNotEmpty && !name.contains(brand) ? '$name ($brand)' : name,
      brand: brand,
      kcal: kcal,
      protein: kcal != null && anyMacro ? (protein ?? 0) : protein,
      carbs: kcal != null && anyMacro ? (carbs ?? 0) : carbs,
      fat: kcal != null && anyMacro ? (fat ?? 0) : fat,
      fiber: read('fiber_100g'),
      servingG: serving,
    );
  }
}

class OpenFoodFactsClient {
  final http.Client _client;

  OpenFoodFactsClient([http.Client? client]) : _client = client ?? http.Client();

  /// Looks a barcode up online. Throws on network errors, returns null if unknown.
  Future<OffProduct?> lookup(String barcode) async {
    final uri = Uri.https('world.openfoodfacts.org', '/api/v2/product/$barcode.json', {
      'fields': 'product_name,product_name_ar,product_name_fr,product_name_en,brands,nutriments,serving_quantity',
    });
    // Generic user agent as requested by OFF (no personal data).
    final res = await _client.get(uri, headers: {'User-Agent': 'FitCompanion/1.1 (Android; offline-first fitness app)'}).timeout(
          const Duration(seconds: 12),
        );
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return OffProduct.fromResponse(barcode, jsonDecode(res.body) as Map<String, dynamic>);
  }
}
