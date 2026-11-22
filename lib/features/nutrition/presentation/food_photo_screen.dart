import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/cloud_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../coach/coach_context.dart';
import 'eaten_widgets.dart';
import 'nutrition_providers.dart';

class _Item {
  String name;
  double grams;
  final double kcal100, p100, c100, f100;

  _Item(this.name, this.grams, double kcal, double p, double c, double f)
      : kcal100 = grams > 0 ? kcal * 100 / grams : 0,
        p100 = grams > 0 ? p * 100 / grams : 0,
        c100 = grams > 0 ? c * 100 / grams : 0,
        f100 = grams > 0 ? f * 100 / grams : 0;

  double get kcal => kcal100 * grams / 100;
  double get protein => p100 * grams / 100;
  double get carbs => c100 * grams / 100;
  double get fat => f100 * grams / 100;
}

/// Photograph a plate / food / product → AI identifies the items, portions,
/// calories and macros, comments on the meal and suggests additions if needed.
class FoodPhotoScreen extends ConsumerStatefulWidget {
  final String? mealType;
  const FoodPhotoScreen({super.key, this.mealType});

  @override
  ConsumerState<FoodPhotoScreen> createState() => _FoodPhotoScreenState();
}

class _FoodPhotoScreenState extends ConsumerState<FoodPhotoScreen> {
  Uint8List? _image;
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  String? _dish;
  String _confidence = 'medium';
  String _analysis = '';
  List<String> _suggestions = const [];
  List<_Item> _items = [];

  late String _meal = widget.mealType ?? _guessMeal();
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
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _image = bytes;
      _items = [];
      _dish = null;
      _error = null;
    });
    _analyze();
  }

  Future<void> _analyze() async {
    final l10n = AppLocalizations.of(context)!;
    if (_image == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ctx = await CoachContextBuilder(ref.read(databaseProvider)).build();
      final r = await ref.read(cloudServiceProvider).analyzeImages(
            mode: 'food_photo',
            images: [VisionImage(_image!)],
            language: ref.read(localeProvider).languageCode,
            extra: {'note': _note.text.trim(), 'context': ctx},
          );
      if (r['is_food'] == false) {
        setState(() => _error = l10n.photoNotFood);
        return;
      }
      HapticFeedback.mediumImpact();
      setState(() {
        _dish = (r['dish_name'] as String?) ?? '';
        _confidence = (r['confidence'] as String?) ?? 'medium';
        _analysis = (r['analysis'] as String?) ?? '';
        _suggestions = [for (final s in (r['suggestions'] as List? ?? const [])) s.toString()];
        _items = [
          for (final raw in (r['items'] as List? ?? const []))
            () {
              final m = Map<String, dynamic>.from(raw as Map);
              double d(String k) => (m[k] as num?)?.toDouble() ?? 0;
              return _Item(m['name'].toString(), d('grams'), d('kcal'), d('protein'), d('carbs'), d('fat'));
            }(),
        ];
      });
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
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _log() async {
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(nutritionRepositoryProvider);
    final day = ref.read(selectedDateProvider);
    final now = DateTime.now();
    final ts = DateTime(day.year, day.month, day.day, now.hour, now.minute);
    for (final i in _items.where((i) => i.grams > 0)) {
      await repo.logCustomEntry(
        name: i.name,
        grams: i.grams,
        calories: double.parse(i.kcal.toStringAsFixed(1)),
        protein: double.parse(i.protein.toStringAsFixed(1)),
        carbs: double.parse(i.carbs.toStringAsFixed(1)),
        fat: double.parse(i.fat.toStringAsFixed(1)),
        mealType: _meal,
        timestamp: ts,
        isEaten: _eaten,
        eatenAt: DateTime(day.year, day.month, day.day, _time.hour, _time.minute),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.photoLogged(_items.length))));
    context.go('/nutrition');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final signedIn = ref.watch(cloudServiceProvider).user != null;
    final totalKcal = _items.fold<double>(0, (a, i) => a + i.kcal);
    final totalP = _items.fold<double>(0, (a, i) => a + i.protein);
    final totalC = _items.fold<double>(0, (a, i) => a + i.carbs);
    final totalF = _items.fold<double>(0, (a, i) => a + i.fat);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.photoTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          // ---------------- Photo ----------------
          AppCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.radiusLg),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconBadge(icon: Icons.restaurant_rounded, color: theme.colorScheme.primary, gradient: context.accentGradient, size: 64, iconSize: 32),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(l10n.photoHint, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_image!, fit: BoxFit.cover),
                          if (_busy)
                            Container(
                              color: Colors.black45,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(color: Colors.white),
                                  const SizedBox(height: 12),
                                  Text(l10n.photoAnalyzing, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: Text(l10n.photosCamera),
                  onPressed: _busy || !signedIn ? null : () => _pick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_rounded),
                  label: Text(l10n.photosGallery),
                  onPressed: _busy || !signedIn ? null : () => _pick(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            decoration: InputDecoration(labelText: l10n.photoNote, hintText: l10n.photoNoteHint, prefixIcon: const Icon(Icons.edit_note_rounded)),
          ),
          if (!signedIn)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.myFoodNeedAccount, style: theme.textTheme.bodySmall)),
                  TextButton(onPressed: () => context.push('/settings/cloud'), child: Text(l10n.cloudTitle)),
                ],
              ),
            ),
          if (_image != null && !_busy && _items.isEmpty && _error == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.icon(onPressed: _analyze, icon: const Icon(Icons.auto_awesome_rounded), label: Text(l10n.myFoodAnalyze)),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(_error!, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),

          // ---------------- Results ----------------
          if (_items.isNotEmpty) ...[
            SectionHeader(title: _dish?.isNotEmpty == true ? _dish! : l10n.photoResults),
            AppCard(
              gradient: context.heroGradient,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: '${totalKcal.round()} ', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                          TextSpan(text: l10n.commonKcal, style: theme.textTheme.bodyMedium),
                        ])),
                      ),
                      Pill(
                        label: switch (_confidence) { 'high' => l10n.myFoodConfHigh, 'low' => l10n.myFoodConfLow, _ => l10n.myFoodConfMedium },
                        color: switch (_confidence) { 'high' => AppColors.success, 'low' => AppColors.flame, _ => AppColors.carbs },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _Macro(label: l10n.dashboardProtein, value: totalP, color: AppColors.protein),
                      _Macro(label: l10n.dashboardCarbs, value: totalC, color: AppColors.carbs),
                      _Macro(label: l10n.dashboardFat, value: totalF, color: AppColors.fat),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_items[i].name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                            Text(
                              '${_items[i].kcal.round()} ${l10n.commonKcal} • P ${_items[i].protein.toStringAsFixed(0)} • C ${_items[i].carbs.toStringAsFixed(0)} • F ${_items[i].fat.toStringAsFixed(0)}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      // Portion editor: values scale with the weight
                      SizedBox(
                        width: 84,
                        child: TextFormField(
                          initialValue: _items[i].grams.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(isDense: true, suffixText: l10n.commonGrams, contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6)),
                          onChanged: (v) => setState(() => _items[i].grams = double.tryParse(v) ?? 0),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.error),
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              ),
            if (_analysis.isNotEmpty) ...[
              const SizedBox(height: 4),
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.insights_rounded, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_analysis, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45))),
                  ],
                ),
              ),
            ],
            // Suggestions only when the AI found something to improve
            if (_suggestions.isNotEmpty) ...[
              SectionHeader(title: l10n.photoSuggestions),
              AppCard(
                backgroundColor: AppColors.success.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in _suggestions)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(child: Text(s, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            SectionHeader(title: l10n.myFoodLogNow),
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
            const SizedBox(height: 10),
            EatenToggleCard(
              eaten: _eaten,
              time: _time,
              onEatenChanged: (v) => setState(() => _eaten = v),
              onTimeChanged: (t) => setState(() => _time = t),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: Text(l10n.myFoodSaveAndLog),
                onPressed: _items.isEmpty ? null : _log,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Macro({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text('${value.toStringAsFixed(0)}g', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: color)),
          Text(label, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
