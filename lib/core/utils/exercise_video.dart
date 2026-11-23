import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// YouTube search for an exercise's form demo (English name gives the best results).
Uri exerciseVideoUri(String englishName) => Uri.https('www.youtube.com', '/results', {
      'search_query': '$englishName exercise proper form',
    });

/// Opens the demo in the YouTube app (or the browser if it isn't installed).
Future<void> openExerciseVideo(BuildContext context, String englishName) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  final ok = await launchUrl(exerciseVideoUri(englishName), mode: LaunchMode.externalApplication).catchError((_) => false);
  if (!ok) messenger.showSnackBar(SnackBar(content: Text(l10n.exerciseVideoError)));
}

/// Compact "Watch how" button.
class ExerciseVideoButton extends StatelessWidget {
  final String englishName;
  const ExerciseVideoButton({super.key, required this.englishName});

  @override
  Widget build(BuildContext context) => FilledButton.tonalIcon(
        onPressed: () => openExerciseVideo(context, englishName),
        icon: const Icon(Icons.play_circle_fill_rounded),
        label: Text(AppLocalizations.of(context)!.exerciseWatchHow),
      );
}
