import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/backup_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService(ref.watch(databaseProvider)));

/// Local backup to a JSON file (share to Drive / Telegram / email…) and restore.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      final json = await ref.read(backupServiceProvider).exportJson();
      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final name = 'fit_companion_backup_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}.json';
      final file = File(p.join(dir.path, name));
      await file.writeAsString(json);
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/json')], subject: name));
    } catch (e) {
      _toast('${l10n.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await FilePicker.pickFile(type: FileType.any);
    if (picked == null) return;
    String json;
    try {
      json = await picked.xFile.readAsString();
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (map['format'] != BackupService.format) throw const FormatException();
    } catch (_) {
      _toast(l10n.backupInvalid);
      return;
    }
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.backupRestore),
        content: Text(l10n.backupRestoreConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.backupRestore),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref.read(backupServiceProvider).restoreJson(json);
      _toast(l10n.backupRestored);
    } catch (e) {
      _toast('${l10n.commonError}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.backupSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          AppCard(
            onTap: _busy ? null : _export,
            child: Row(
              children: [
                IconBadge(icon: Icons.upload_file_rounded, color: AppColors.lime, gradient: AppColors.limeGradient, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.backupExport, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(l10n.backupExportDesc, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          AppCard(
            onTap: _busy ? null : _restore,
            child: Row(
              children: [
                IconBadge(icon: Icons.settings_backup_restore_rounded, color: AppColors.violet, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.backupRestore, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      Text(l10n.backupRestoreDesc, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_busy) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator())),
          const SizedBox(height: 16),
          Text(l10n.backupPhotosNote, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
