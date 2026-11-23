import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../l10n/app_localizations.dart';
import '../services/cloud_service.dart';

/// YouTube search for an exercise's form demo (English name gives the best results).
Uri exerciseVideoUri(String englishName) => Uri.https('www.youtube.com', '/results', {
      'search_query': '$englishName exercise proper form',
    });

/// Opens [uri] (default: the YouTube search) in the YouTube app or the browser.
Future<void> openExerciseVideo(BuildContext context, String englishName, {Uri? uri}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final ok = await launchUrl(uri ?? exerciseVideoUri(englishName), mode: LaunchMode.externalApplication).catchError((_) => false);
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(l10n.exerciseVideoError)));
}

/// Demo videos for an exercise (cached on Supabase, looked up once per exercise).
final exerciseVideosProvider = FutureProvider.autoDispose.family<List<ExerciseVideo>, String>(
  (ref, englishName) => ref.watch(cloudServiceProvider).exerciseVideos(englishName),
);

/// Shows the demo inside the app in a bottom sheet (used during a workout).
Future<void> showExerciseVideoSheet(BuildContext context, {required String englishName, required String title}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ExerciseVideoPlayer(englishName: englishName, autoPlay: true),
            ],
          ),
        ),
      ),
    );

/// In-app YouTube player: thumbnail first (no WebView until you tap), then plays inline.
/// Fullscreen by rotating the phone or with the player's button. Falls back to opening YouTube.
class ExerciseVideoPlayer extends ConsumerStatefulWidget {
  final String englishName;
  final bool autoPlay;
  const ExerciseVideoPlayer({super.key, required this.englishName, this.autoPlay = false});

  @override
  ConsumerState<ExerciseVideoPlayer> createState() => _ExerciseVideoPlayerState();
}

class _ExerciseVideoPlayerState extends ConsumerState<ExerciseVideoPlayer> {
  YoutubePlayerController? _controller;
  int _index = 0;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _play(String id) {
    if (_controller == null) {
      setState(() {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: id,
          autoPlay: true,
          params: const YoutubePlayerParams(showFullscreenButton: true, strictRelatedVideos: true),
        );
      });
    } else {
      _controller!.loadVideoById(videoId: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final async = ref.watch(exerciseVideosProvider(widget.englishName));
    final radius = BorderRadius.circular(16);

    Widget frame(Widget child) => ClipRRect(
          borderRadius: radius,
          child: AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: child)),
        );

    Widget fallback(String message, {bool signIn = false}) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.08), borderRadius: radius),
          child: Column(children: [
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, alignment: WrapAlignment.center, children: [
              if (signIn)
                OutlinedButton(onPressed: () => context.push('/settings/cloud'), child: Text(l10n.aiSignIn)),
              FilledButton.tonalIcon(
                onPressed: () => openExerciseVideo(context, widget.englishName),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.exerciseOpenYoutube),
              ),
            ]),
          ]),
        );

    return async.when(
      loading: () => frame(const Center(child: CircularProgressIndicator())),
      error: (e, _) {
        final code = e is CoachException ? e.code : 'network';
        return fallback(code == 'unauthorized' ? l10n.exerciseVideoSignIn : l10n.exerciseVideoUnavailable, signIn: code == 'unauthorized');
      },
      data: (videos) {
        if (videos.isEmpty) return fallback(l10n.exerciseVideoUnavailable);
        final v = videos[_index % videos.length];
        if (widget.autoPlay && _controller == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _controller == null) _play(v.id);
          });
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            frame(
              _controller != null
                  ? YoutubePlayer(controller: _controller!, aspectRatio: 16 / 9)
                  : InkWell(
                      onTap: () => _play(v.id),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.network(
                          'https://i.ytimg.com/vi/${v.id}/hqdefault.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: Color(0xCCFF0000), shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                          ),
                        ),
                      ]),
                    ),
            ),
            const SizedBox(height: 6),
            Text(v.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            Row(children: [
              Expanded(child: Text(v.channel, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.labelSmall)),
              if (videos.length > 1)
                TextButton.icon(
                  onPressed: () {
                    setState(() => _index++);
                    final next = videos[_index % videos.length];
                    if (_controller != null) _play(next.id);
                  },
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: Text(l10n.exerciseAnotherVideo),
                ),
              IconButton(
                tooltip: l10n.exerciseOpenYoutube,
                icon: const Icon(Icons.open_in_new_rounded, size: 20),
                onPressed: () => openExerciseVideo(context, widget.englishName,
                    uri: Uri.https('www.youtube.com', '/watch', {'v': v.id})),
              ),
            ]),
          ],
        );
      },
    );
  }
}
