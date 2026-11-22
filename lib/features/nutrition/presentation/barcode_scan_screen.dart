import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/app_database.dart';
import '../../../core/services/cloud_service.dart';
import '../../../shared/providers/settings_provider.dart';
import '../data/open_food_facts.dart';
import 'nutrition_providers.dart';

final openFoodFactsProvider = Provider<OpenFoodFactsClient>((ref) => OpenFoodFactsClient());

/// Scans a product barcode → local cache → Open Food Facts → "Add food" screen.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  final String? mealType;

  const BarcodeScanScreen({super.key, this.mealType});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA, BarcodeFormat.upcE],
  );
  bool _busy = false;
  String? _status;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle(String code) async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _status = l10n.scanLooking(code);
    });
    HapticFeedback.mediumImpact();
    final tools = ref.read(mealToolsRepositoryProvider);
    try {
      // 1) Already scanned before (works offline)
      var food = await tools.findByBarcode(code);
      // 2) Open Food Facts
      OffProduct? off;
      if (food == null) {
        try {
          off = await ref.read(openFoodFactsProvider).lookup(code);
        } catch (_) {
          off = null; // network error: fall through to the AI photo option
        }
        if (off != null && off.complete) {
          food = await _save(code, off.name, off.kcal!, off.protein!, off.carbs!, off.fat!, off.fiber, off.servingG);
        } else if (off != null) {
          // 3) Known product but no nutrition table → AI estimate from name/brand
          setState(() => _status = l10n.scanAiEstimating(off!.name));
          food = await _fromAi(code, images: const [], name: off.name);
        }
      }
      if (!mounted) return;
      if (food != null) {
        _open(food.id);
      } else {
        await _notFound(l10n, code);
      }
    } on CoachException catch (e) {
      if (!mounted) return;
      setState(() => _status = e.code == 'unauthorized' ? l10n.myFoodNeedAccount : l10n.coachErrGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _open(String foodId) {
    final meal = widget.mealType != null ? '&meal=${widget.mealType}' : '';
    context.pushReplacement('/nutrition/add?foodId=$foodId$meal');
  }

  Future<Food> _save(String code, String name, double kcal, double p, double c, double f, double? fiber, double? serving) {
    return ref.read(mealToolsRepositoryProvider).saveScannedFood(
          barcode: code,
          name: name,
          caloriesPer100g: kcal,
          proteinPer100g: p,
          carbsPer100g: c,
          fatPer100g: f,
          fiberPer100g: fiber,
          servingWeightG: serving ?? 100,
          servingDescription: '${(serving ?? 100).toStringAsFixed(0)} g',
        );
  }

  /// AI reads the nutrition table from photos (or estimates the product by name).
  Future<Food?> _fromAi(String code, {required List<VisionImage> images, String? name}) async {
    final r = await ref.read(cloudServiceProvider).analyzeImages(
          mode: 'label',
          images: images,
          language: ref.read(localeProvider).languageCode,
          extra: {'barcode': code, if (name != null) 'name': name},
        );
    final per = Map<String, dynamic>.from(r['per100g'] as Map);
    double d(String k) => (per[k] as num?)?.toDouble() ?? 0;
    final productName = (r['product_name'] as String?)?.trim();
    return _save(
      code,
      (productName == null || productName.isEmpty) ? (name ?? code) : productName,
      d('kcal'),
      d('protein'),
      d('carbs'),
      d('fat'),
      d('fiber') > 0 ? d('fiber') : null,
      (r['serving_g'] as num?)?.toDouble(),
    );
  }

  Future<void> _notFound(AppLocalizations l10n, String code) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.photo_camera_rounded, size: 36),
        title: Text(l10n.scanNotFound),
        content: Text(l10n.scanNotFoundAi(code)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, 'again'), child: Text(l10n.scanAgain)),
          TextButton(onPressed: () => Navigator.pop(ctx, 'manual'), child: Text(l10n.scanManual)),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, 'photo'),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(l10n.scanPhotoLabel),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (choice == 'manual') {
      context.pushReplacement('/nutrition/custom${widget.mealType != null ? '?meal=${widget.mealType}' : ''}');
      return;
    }
    if (choice != 'photo') {
      setState(() => _status = null);
      return;
    }
    // Release the scanner camera before opening the photo camera.
    await _controller.stop();
    final photo = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1600, imageQuality: 85);
    if (photo == null) {
      await _controller.start();
      return;
    }
    setState(() {
      _busy = true;
      _status = l10n.scanReadingLabel;
    });
    try {
      final food = await _fromAi(code, images: [VisionImage(await photo.readAsBytes())]);
      if (mounted && food != null) _open(food.id);
    } on CoachException catch (e) {
      if (!mounted) return;
      setState(() => _status = e.code == 'unauthorized' ? l10n.myFoodNeedAccount : l10n.coachErrGeneric);
      await _controller.start();
    } catch (_) {
      if (!mounted) return;
      setState(() => _status = l10n.coachErrNetwork);
      await _controller.start();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.scanTitle),
        actions: [
          IconButton(icon: const Icon(Icons.flashlight_on_rounded), onPressed: _controller.toggleTorch),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              final code = capture.barcodes.map((b) => b.rawValue).whereType<String>().firstOrNull;
              if (code != null) _handle(code);
            },
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.scanCameraError, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),
          // Viewfinder
          Center(
            child: Container(
              width: 270,
              height: 170,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lime, width: 3),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.black.withAlpha(170), borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: [
                  if (_busy)
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.lime))
                  else
                    Icon(Icons.qr_code_scanner_rounded, color: AppColors.lime),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_status ?? l10n.scanHint, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
