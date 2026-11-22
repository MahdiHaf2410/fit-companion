import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/strength_calculator.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../l10n/app_localizations.dart';

/// Offline gym calculators: estimated 1RM (+ % table) and barbell plate loader.
class GymToolsScreen extends StatelessWidget {
  const GymToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.toolsTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
              child: TabBar(tabs: [Tab(text: l10n.tools1RM), Tab(text: l10n.toolsPlates)]),
            ),
          ),
        ),
        body: const TabBarView(children: [_OneRepMaxTab(), _PlatesTab()]),
      ),
    );
  }
}

class _OneRepMaxTab extends StatefulWidget {
  const _OneRepMaxTab();

  @override
  State<_OneRepMaxTab> createState() => _OneRepMaxTabState();
}

class _OneRepMaxTabState extends State<_OneRepMaxTab> {
  final _weight = TextEditingController(text: '80');
  final _reps = TextEditingController(text: '8');

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final w = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 0;
    final r = int.tryParse(_reps.text) ?? 0;
    final orm = StrengthCalculator.estimateOneRepMax(w, r);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(l10n.tools1RMDesc, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _NumField(controller: _weight, label: l10n.toolsWeightKg, onChanged: () => setState(() {}))),
            const SizedBox(width: 10),
            Expanded(child: _NumField(controller: _reps, label: l10n.toolsReps, decimal: false, onChanged: () => setState(() {}))),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          gradient: context.heroGradient,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(l10n.progressEst1RM, style: theme.textTheme.labelMedium),
              AnimatedNumber(
                value: orm,
                decimals: 1,
                suffix: ' ${l10n.commonKg}',
                style: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.primary),
              ),
              Text('Epley: w × (1 + reps / 30)', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (final p in StrengthCalculator.percentTable)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(width: 56, child: Text('$p%', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800))),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(value: p / 100, minHeight: 8),
                        ),
                      ),
                      SizedBox(
                        width: 84,
                        child: Text(
                          '${(orm * p / 100).toStringAsFixed(1)} ${l10n.commonKg}',
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlatesTab extends StatefulWidget {
  const _PlatesTab();

  @override
  State<_PlatesTab> createState() => _PlatesTabState();
}

class _PlatesTabState extends State<_PlatesTab> {
  final _target = TextEditingController(text: '100');
  double _bar = 20;

  static final _plateColors = <double, Color>{
    25.0: Color(0xFFE53935),
    20.0: Color(0xFF1E88E5),
    15.0: Color(0xFFFDD835),
    10.0: Color(0xFF43A047),
    5.0: Color(0xFFF5F5F5),
    2.5: Color(0xFF424242),
    1.25: Color(0xFF9E9E9E),
  };

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final target = double.tryParse(_target.text.replaceAll(',', '.')) ?? 0;
    final result = StrengthCalculator.platesPerSide(target, barKg: _bar);

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(l10n.toolsPlatesDesc, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 14),
        _NumField(controller: _target, label: l10n.toolsTargetKg, onChanged: () => setState(() {})),
        const SizedBox(height: 12),
        Text(l10n.toolsBarKg, style: theme.textTheme.labelMedium),
        const SizedBox(height: 6),
        SegmentedButton<double>(
          segments: const [
            ButtonSegment(value: 20, label: Text('20')),
            ButtonSegment(value: 15, label: Text('15')),
            ButtonSegment(value: 10, label: Text('10')),
          ],
          selected: {_bar},
          onSelectionChanged: (s) => setState(() => _bar = s.first),
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Barbell visual (one side)
              SizedBox(
                height: 120,
                child: Row(
                  children: [
                    Container(width: 26, height: 14, decoration: BoxDecoration(color: context.textSecondary, borderRadius: BorderRadius.circular(3))),
                    Container(width: 8, height: 40, color: context.textSecondary),
                    if (result.plates.isEmpty)
                      Expanded(child: Center(child: Text(l10n.toolsOnlyBar, style: theme.textTheme.bodyMedium)))
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (int i = 0; i < result.plates.length; i++)
                                TweenAnimationBuilder<double>(
                                  key: ValueKey('${result.plates.length}-$i-${result.plates[i]}'),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(milliseconds: 250 + i * 60),
                                  curve: Curves.easeOutBack,
                                  builder: (_, v, child) => Transform.scale(scaleY: v, child: child),
                                  child: Container(
                                    margin: const EdgeInsetsDirectional.only(end: 3),
                                    width: result.plates[i] >= 10 ? 18 : 13,
                                    height: 40 + result.plates[i] * 3.0,
                                    decoration: BoxDecoration(
                                      color: _plateColors[result.plates[i]] ?? AppColors.violet,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.black26),
                                    ),
                                  ),
                                ),
                              Container(width: 40, height: 14, color: context.textSecondary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(l10n.toolsPerSide, style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final p in result.plates)
                    Pill(label: '${p % 1 == 0 ? p.toInt() : p} ${l10n.commonKg}', color: theme.colorScheme.primary),
                ],
              ),
              if (result.remainderKg > 0) ...[
                const SizedBox(height: 10),
                Text(l10n.toolsRemainder(result.remainderKg.toString()), style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool decimal;
  final VoidCallback onChanged;

  const _NumField({required this.controller, required this.label, required this.onChanged, this.decimal = true});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      style: Theme.of(context).textTheme.titleLarge,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => onChanged(),
    );
  }
}
