import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../l10n/app_localizations.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  String _jsonDump = '';
  bool _isLoading = true;
  int _logsCount = 0;
  int _sessionsCount = 0;
  int _metricsCount = 0;

  @override
  void initState() {
    super.initState();
    _exportData();
  }

  Future<void> _exportData() async {
    final db = ref.read(databaseProvider);
    final profile = await (db.select(db.profiles)..limit(1)).getSingleOrNull();
    final goal = await (db.select(db.goals)..limit(1)).getSingleOrNull();
    final logs = await db.select(db.foodLogs).get();
    final sessions = await db.select(db.workoutSessions).get();
    final sets = await db.select(db.workoutSets).get();
    final metrics = await db.select(db.bodyMetrics).get();

    final exportMap = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'profile': profile?.toJson(),
      'goal': goal?.toJson(),
      'foodLogs': logs.map((l) => l.toJson()).toList(),
      'workoutSessions': sessions.map((s) => s.toJson()).toList(),
      'workoutSets': sets.map((st) => st.toJson()).toList(),
      'bodyMetrics': metrics.map((m) => m.toJson()).toList(),
    };

    final encoder = const JsonEncoder.withIndent('  ');
    final formatted = encoder.convert(exportMap);

    if (mounted) {
      setState(() {
        _jsonDump = formatted;
        _logsCount = logs.length;
        _sessionsCount = sessions.length;
        _metricsCount = metrics.length;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileExportJson),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy JSON',
            onPressed: _jsonDump.isNotEmpty
                ? () {
                    Clipboard.setData(ClipboardData(text: _jsonDump));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('JSON copied to clipboard!')),
                    );
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Summary',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text('• Food Logs: $_logsCount'),
                        Text('• Workout Sessions: $_sessionsCount'),
                        Text('• Body Metrics: $_metricsCount'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'JSON Raw Backup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _jsonDump,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
