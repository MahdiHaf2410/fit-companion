import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../domain/academy_lesson.dart';
import '../../../l10n/app_localizations.dart';

final academyProgressStreamProvider = StreamProvider((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllAcademyProgress();
});

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';
    final progressAsync = ref.watch(academyProgressStreamProvider);

    final allLessons = AcademyCatalog.lessons;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.academyTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.academySubtitle,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Progress Header Card
            progressAsync.when(
              data: (progressList) {
                final completedCount = progressList.where((p) => p.isCompleted).length;
                final ratio = allLessons.isNotEmpty ? completedCount / allLessons.length : 0.0;

                return AppCard(
                  backgroundColor: theme.colorScheme.primary.withAlpha(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.school_rounded, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Your Learning Journey',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            "$completedCount / ${allLessons.length}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.outline.withAlpha(40),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${(ratio * 100).toInt()}% completed",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            Text(
              'Lessons (14 Topics)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Lessons List
            progressAsync.when(
              data: (progressList) {
                final completedMap = {for (var p in progressList) p.lessonId: p};

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allLessons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final lesson = allLessons[i];
                    final progress = completedMap[lesson.id];
                    final isDone = progress?.isCompleted ?? false;
                    final title = isAr ? lesson.titleAr : lesson.titleEn;
                    final category = isAr ? lesson.categoryAr : lesson.categoryEn;

                    return AppCard(
                      onTap: () {
                        context.push('/nutrition/academy/lesson/${lesson.id}');
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isDone
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primaryContainer,
                            foregroundColor: isDone
                                ? Colors.white
                                : theme.colorScheme.primary,
                            child: isDone
                                ? const Icon(Icons.check_rounded, size: 20)
                                : Text('${lesson.number}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.outline.withAlpha(30),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    if (isDone) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.academyCompleted,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              error: (e, _) => Text('${l10n.commonError}: $e'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
