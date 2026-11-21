import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import 'progress_providers.dart';
import '../../../l10n/app_localizations.dart';

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
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _notesController.dispose();
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
      notes: notes,
      date: _selectedDate,
    );

    ref.invalidate(bodyMetricsStreamProvider);
    ref.invalidate(latestBodyMetricProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Measurement saved successfully!')),
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
              const SizedBox(height: 16),

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
