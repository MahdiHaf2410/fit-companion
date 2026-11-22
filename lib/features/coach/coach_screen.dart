import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/cloud_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/settings_provider.dart';
import 'coach_context.dart';

/// Chat with the Gemini-powered coach (via Supabase Edge Function `ai-coach`).
class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <CoachMessage>[];
  _Attachment? _attach;
  bool _loading = true;
  bool _sending = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final cloud = ref.read(cloudServiceProvider);
    try {
      final h = await cloud.coachHistory();
      _messages
        ..clear()
        ..addAll(h);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
    _toBottom();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  String _errorText(AppLocalizations l10n, String code) => switch (code) {
        'missing_gemini_key' || 'gemini_key' => l10n.coachErrNoKey,
        'gemini_model' => l10n.coachErrModel,
        'gemini_busy' || 'empty_reply' => l10n.coachErrBusy,
        'unauthorized' => l10n.coachNeedsAccount,
        'daily_limit' => l10n.coachErrLimit,
        'media_too_big' => l10n.coachErrMediaBig,
        'upload_failed' || 'media_not_found' => l10n.coachErrUpload,
        'media_unsupported' => l10n.coachErrMediaType,
        'gemini_quota' => l10n.coachErrQuota,
        _ => l10n.coachErrGeneric,
      };

  Future<void> _pickMedia() async {
    final l10n = AppLocalizations.of(context)!;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.photo_camera_rounded), title: Text(l10n.coachTakePhoto), onTap: () => Navigator.pop(ctx, 'pc')),
            ListTile(leading: const Icon(Icons.photo_library_rounded), title: Text(l10n.coachPickPhoto), onTap: () => Navigator.pop(ctx, 'pg')),
            ListTile(leading: const Icon(Icons.videocam_rounded), title: Text(l10n.coachRecordVideo), onTap: () => Navigator.pop(ctx, 'vc')),
            ListTile(leading: const Icon(Icons.video_library_rounded), title: Text(l10n.coachPickVideo), onTap: () => Navigator.pop(ctx, 'vg')),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final picker = ImagePicker();
    final source = choice.endsWith('c') ? ImageSource.camera : ImageSource.gallery;
    final isVideo = choice.startsWith('v');
    final XFile? f = isVideo
        ? await picker.pickVideo(source: source, maxDuration: const Duration(seconds: 60))
        : await picker.pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (bytes.length > 40 * 1024 * 1024) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.coachErrMediaBig)));
      return;
    }
    var ext = (f.name.contains('.') ? f.name.split('.').last : '').toLowerCase();
    final String mime;
    if (isVideo) {
      mime = switch (ext) { 'mov' => 'video/quicktime', '3gp' => 'video/3gpp', 'webm' => 'video/webm', _ => 'video/mp4' };
      if (!['mov', '3gp', 'webm', 'mp4'].contains(ext)) ext = 'mp4';
    } else {
      mime = switch (ext) { 'png' => 'image/png', 'webp' => 'image/webp', _ => 'image/jpeg' };
      if (!['png', 'webp'].contains(ext)) ext = 'jpg';
    }
    setState(() => _attach = _Attachment(bytes, mime, ext, isVideo));
  }

  Future<void> _send([String? preset]) async {
    final l10n = AppLocalizations.of(context)!;
    final text = (preset ?? _input.text).trim();
    final attach = _attach;
    if ((text.isEmpty && attach == null) || _sending) return;
    _input.clear();
    setState(() {
      _sending = true;
      _attach = null;
      _messages.add(CoachMessage(
        role: 'user',
        text: text,
        mediaType: attach == null ? null : (attach.isVideo ? 'video' : 'image'),
        localBytes: attach != null && !attach.isVideo ? attach.bytes : null,
      ));
    });
    _toBottom();
    try {
      final cloud = ref.read(cloudServiceProvider);
      String? path;
      if (attach != null) {
        setState(() => _status = l10n.coachUploading);
        path = await cloud.uploadCoachMedia(attach.bytes, mime: attach.mime, extension: attach.ext);
        if (mounted) setState(() => _status = attach.isVideo ? l10n.coachAnalyzingVideo : null);
      }
      final summary = await CoachContextBuilder(ref.read(databaseProvider)).build();
      final reply = await cloud.askCoach(
        message: text,
        context: summary,
        language: ref.read(localeProvider).languageCode,
        mediaPath: path,
        mediaMime: attach?.mime,
      );
      if (mounted) setState(() => _messages.add(CoachMessage(role: 'model', text: reply)));
    } on CoachException catch (e) {
      if (mounted) setState(() => _messages.add(CoachMessage(role: 'error', text: _errorText(l10n, e.code))));
    } catch (_) {
      if (mounted) setState(() => _messages.add(CoachMessage(role: 'error', text: l10n.coachErrNetwork)));
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _status = null;
        });
      }
      _toBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cloud = ref.watch(cloudServiceProvider);
    final signedIn = cloud.user != null;

    if (!signedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.coachTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBadge(icon: Icons.smart_toy_rounded, color: AppColors.violet, gradient: AppColors.violetGradient, size: 72, iconSize: 36),
                const SizedBox(height: 16),
                Text(l10n.coachNeedsAccount, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cloud_rounded),
                  label: Text(l10n.cloudTitle),
                  onPressed: () async {
                    await context.push('/settings/cloud');
                    if (mounted) setState(() {});
                    _load();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final suggestions = [l10n.coachSuggest1, l10n.coachSuggest2, l10n.coachSuggest3, l10n.coachSuggest4];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.coachTitle),
        actions: [
          IconButton(
            tooltip: l10n.coachClear,
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () async {
              await ref.read(cloudServiceProvider).clearCoachHistory();
              setState(_messages.clear);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    children: [
                      AppCard(
                        gradient: context.heroGradient,
                        child: Text(l10n.coachIntro, style: theme.textTheme.bodySmall),
                      ),
                      const SizedBox(height: 10),
                      if (_messages.isEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [for (final s in suggestions) ActionChip(label: Text(s), onPressed: () => _send(s))],
                        ),
                      for (final m in _messages) _Bubble(message: m),
                      if (_sending)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
                              if (_status != null) ...[
                                const SizedBox(width: 10),
                                Flexible(child: Text(_status!, style: Theme.of(context).textTheme.bodySmall)),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_attach != null) _AttachPreview(attach: _attach!, onRemove: () => setState(() => _attach = null)),
                  Row(
                children: [
                  IconButton(
                    tooltip: l10n.coachAttach,
                    onPressed: _sending ? null : _pickMedia,
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(hintText: l10n.coachHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
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

class _Attachment {
  final Uint8List bytes;
  final String mime;
  final String ext;
  final bool isVideo;
  const _Attachment(this.bytes, this.mime, this.ext, this.isVideo);
}

class _AttachPreview extends StatelessWidget {
  final _Attachment attach;
  final VoidCallback onRemove;
  const _AttachPreview({required this.attach, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: attach.isVideo
                ? Container(width: 54, height: 54, color: context.cardHigh, child: const Icon(Icons.play_circle_fill_rounded, size: 30))
                : Image.memory(attach.bytes, width: 54, height: 54, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${attach.isVideo ? l10n.coachVideoAttached : l10n.coachPhotoAttached} • ${(attach.bytes.length / 1048576).toStringAsFixed(1)} MB',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: onRemove),
        ],
      ),
    );
  }
}

class _Bubble extends ConsumerWidget {
  final CoachMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final mine = message.role == 'user';
    final error = message.role == 'error';
    final maxW = MediaQuery.of(context).size.width * 0.82;

    Widget? media;
    if (message.mediaType == 'image') {
      media = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: message.localBytes != null
            ? Image.memory(message.localBytes!, width: maxW * 0.7, fit: BoxFit.cover)
            : (message.mediaPath == null
                ? const SizedBox.shrink()
                : FutureBuilder<String?>(
                    future: ref.read(cloudServiceProvider).coachMediaUrl(message.mediaPath!),
                    builder: (_, snap) => snap.data == null
                        ? Container(width: maxW * 0.7, height: 120, color: context.cardHigh, child: const Icon(Icons.image_rounded))
                        : Image.network(
                            snap.data!,
                            width: maxW * 0.7,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded),
                          ),
                  )),
      );
    } else if (message.mediaType == 'video') {
      media = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Text(l10n.coachVideoAttached, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ]),
      );
    }

    return Align(
      alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxW),
        decoration: BoxDecoration(
          color: error ? AppColors.error.withAlpha(30) : (mine ? theme.colorScheme.primary : theme.colorScheme.surface),
          borderRadius: BorderRadius.circular(18),
          border: mine ? null : Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (media != null) media,
            if (media != null && message.text.isNotEmpty) const SizedBox(height: 8),
            if (message.text.isNotEmpty)
              SelectableText(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: mine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
