import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/services/cloud_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/settings_provider.dart';

final cloudStatusProvider = FutureProvider.autoDispose<CloudStatus>((ref) => ref.watch(cloudServiceProvider).status());
final cloudAutoSyncProvider = FutureProvider.autoDispose<bool>((ref) => ref.watch(cloudServiceProvider).isAutoSync());

class CloudScreen extends ConsumerStatefulWidget {
  const CloudScreen({super.key});

  @override
  ConsumerState<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends ConsumerState<CloudScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _register = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _run(Future<void> Function() job) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      await job();
    } catch (e) {
      _toast('${l10n.commonError}: ${e is StateError ? e.message : e}');
    } finally {
      if (mounted) setState(() => _busy = false);
      ref.invalidate(cloudStatusProvider);
    }
  }

  Future<void> _auth() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    final pass = _password.text;
    if (!email.contains('@') || pass.length < 6) {
      _toast(l10n.cloudInvalidForm);
      return;
    }
    await _run(() async {
      final cloud = ref.read(cloudServiceProvider);
      if (_register) {
        final r = await cloud.signUp(email, pass);
        _toast(r == SignUpResult.confirmEmail ? l10n.cloudConfirmEmail : l10n.cloudSignedIn);
      } else {
        await cloud.signIn(email, pass);
        _toast(l10n.cloudSignedIn);
      }
    });
  }

  Future<bool> _confirm(String title, String body) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonConfirm)),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider).languageCode;
    final status = ref.watch(cloudStatusProvider);
    final auto = ref.watch(cloudAutoSyncProvider).value ?? false;
    String fmt(DateTime? d) => d == null ? '—' : DateFormat.yMMMd(locale).add_Hm().format(d.toLocal());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.cloudTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Text(l10n.cloudSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          status.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (s) {
              if (!s.enabled) return AppCard(child: Text(l10n.cloudUnavailable));
              if (!s.signedIn) {
                return AppCard(
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        SegmentedButton<bool>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(value: false, label: Text(l10n.cloudSignIn)),
                            ButtonSegment(value: true, label: Text(l10n.cloudCreateAccount)),
                          ],
                          selected: {_register},
                          onSelectionChanged: (v) => setState(() => _register = v.first),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(labelText: l10n.cloudEmail, prefixIcon: const Icon(Icons.alternate_email_rounded)),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _password,
                          obscureText: true,
                          autofillHints: [_register ? AutofillHints.newPassword : AutofillHints.password],
                          decoration: InputDecoration(labelText: l10n.cloudPassword, prefixIcon: const Icon(Icons.lock_rounded)),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _auth,
                            child: Text(_register ? l10n.cloudCreateAccount : l10n.cloudSignIn),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  AppCard(
                    gradient: context.heroGradient,
                    child: Row(
                      children: [
                        IconBadge(icon: Icons.cloud_done_rounded, color: AppColors.cyan, size: 48),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.email!, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              Text('${l10n.cloudLastSync}: ${fmt(s.lastSyncedAt)}', style: theme.textTheme.bodySmall),
                              Text('${l10n.cloudCloudCopy}: ${fmt(s.remoteUpdatedAt)}', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (s.remoteIsNewer) ...[
                    const SizedBox(height: 10),
                    AppCard(
                      backgroundColor: AppColors.warning.withAlpha(30),
                      child: Text(l10n.cloudRemoteNewer, style: theme.textTheme.bodySmall),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cloud_upload_rounded),
                          label: Text(l10n.cloudUpload),
                          onPressed: _busy
                              ? null
                              : () async {
                                  if (s.remoteIsNewer && !await _confirm(l10n.cloudUpload, l10n.cloudUploadOverwrite)) return;
                                  await _run(() async {
                                    await ref.read(cloudServiceProvider).push(device: 'manual');
                                    _toast(l10n.cloudUploaded);
                                  });
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.cloud_download_rounded),
                          label: Text(l10n.cloudDownload),
                          onPressed: _busy || s.remoteUpdatedAt == null
                              ? null
                              : () async {
                                  if (!await _confirm(l10n.cloudDownload, l10n.cloudDownloadOverwrite)) return;
                                  await _run(() async {
                                    await ref.read(cloudServiceProvider).pull();
                                    _toast(l10n.cloudDownloaded);
                                  });
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.cloudAuto),
                      subtitle: Text(l10n.cloudAutoDesc, style: theme.textTheme.bodySmall),
                      value: auto,
                      onChanged: (v) async {
                        await ref.read(cloudServiceProvider).setAutoSync(v);
                        ref.invalidate(cloudAutoSyncProvider);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(l10n.cloudSignOut),
                    onPressed: _busy ? null : () => _run(() => ref.read(cloudServiceProvider).signOut()),
                  ),
                ],
              );
            },
          ),
          if (_busy) const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator()),
          const SizedBox(height: 12),
          Text(l10n.cloudPrivacy, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
