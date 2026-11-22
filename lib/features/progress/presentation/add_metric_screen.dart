import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'progress_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/services/health_service.dart';

class AddMetricScreen extends ConsumerStatefulWidget {
  const AddMetricScreen({super.key});

  @override
  ConsumerState<AddMetricScreen> createState() => _AddMetricScreenState();
}

class _AddMetricScreenState extends ConsumerState<AddMetricScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _notesController = TextEditingController();
  // v3 optional body measurements
  final _chest = TextEditingController();
  final _arm = TextEditingController();
  final _thigh = TextEditingController();
  final _hips = TextEditingController();
  final _bodyFat = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _notesController.dispose();
    for (final c in [_chest, _arm, _thigh, _hips, _bodyFat]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveMetric() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final waist = double.tryParse(_waistController.text);
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    await ref.read(progressRepositoryProvider).logMetric(
      weightKg: weight,
      waistCm: waist,
      chestCm: double.tryParse(_chest.text.replaceAll(',', '.')),
      armCm: double.tryParse(_arm.text.replaceAll(',', '.')),
      thighCm: double.tryParse(_thigh.text.replaceAll(',', '.')),
      hipsCm: double.tryParse(_hips.text.replaceAll(',', '.')),
      bodyFatPercent: double.tryParse(_bodyFat.text.replaceAll(',', '.')),
      notes: notes,
      date: _selectedDate,
    );

    // Also send the weight to Health Connect when the user connected it.
    final health = ref.read(healthServiceProvider);
    if (await health.hasAccess()) await health.writeWeight(weight, _selectedDate);

    ref.invalidate(bodyMetricsStreamProvider);
    ref.invalidate(latestBodyMetricProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.measureSaved)),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.progressAddMetric),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker tile
              AppCard(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.progressDate, style: theme.textTheme.bodySmall),
                          Text(
                            DateFormat.yMMMd(currentLocale.languageCode).format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weight input
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.onboardingWeight,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                  suffixText: l10n.commonKg,
                ),
                validator: (v) {
                  final val = double.tryParse(v ?? '');
                  if (val == null || val < 20 || val > 350) {
                    return 'Please enter a valid weight (20-350 kg)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Waist input
              TextFormField(
                controller: _waistController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.progressWaist,
                  prefixIcon: const Icon(Icons.straighten_rounded),
                  suffixText: l10n.commonCm,
                ),
              ),
              const SizedBox(height: 8),
              // Optional full body measurements
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  leading: const Icon(Icons.accessibility_new_rounded),
                  title: Text(l10n.measureMore),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  children: [
                    for (final f in [
                      (_chest, l10n.measureChest, l10n.commonCm),
                      (_arm, l10n.measureArm, l10n.commonCm),
                      (_thigh, l10n.measureThigh, l10n.commonCm),
                      (_hips, l10n.measureHips, l10n.commonCm),
                      (_bodyFat, l10n.measureBodyFat, '%'),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: f.$1,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(labelText: f.$2, suffixText: f.$3),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Notes input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (e.g. morning fasted)',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveMetric,
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
