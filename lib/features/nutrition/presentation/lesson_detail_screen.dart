import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../domain/academy_lesson.dart';
import 'academy_screen.dart';
import '../../../l10n/app_localizations.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonDetailScreen({
    super.key,
    required this.lessonId,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  bool _isCompleted = false;
  int _quizScore = 0;
  bool _isLoading = true;

  // Interactive Mini-Tool State: Macro 4-4-9 Explorer
  double _toolProtein = 30.0;
  double _toolCarbs = 45.0;
  double _toolFat = 12.0;

  // Interactive Mini-Tool State: Portion Scaler
  double _toolGrams = 150.0;
  final double _toolBaseCaloriesPer100g = 165.0; // e.g. chicken breast or couscous

  // Interactive Mini-Tool State: Energy Explorer
  double _toolBmr = 1700.0;
  double _toolActivityFactor = 1.55;
  double _toolGoalDelta = -400.0; // deficit

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final db = ref.read(databaseProvider);
    final progress = await db.getLessonProgress(widget.lessonId);
    if (mounted) {
      setState(() {
        if (progress != null) {
          _isCompleted = progress.isCompleted;
          _quizScore = progress.quizScore;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _completeLesson(int score) async {
    final db = ref.read(databaseProvider);
    await db.saveLessonProgress(
      lessonId: widget.lessonId,
      isCompleted: true,
      quizScore: score,
    );
    // Invalidate stream to update academy screen
    ref.invalidate(academyProgressStreamProvider);

    if (mounted) {
      setState(() {
        _isCompleted = true;
        _quizScore = score;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            score == 100
                ? 'Outstanding! Lesson marked as completed.'
                : 'Good effort! Lesson marked as completed.',
          ),
          backgroundColor: score == 100 ? Colors.green : Colors.blueGrey,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isAr = currentLocale.languageCode == 'ar';

    final allLessons = AcademyCatalog.lessons;
    final lessonIndex = allLessons.indexWhere((l) => l.id == widget.lessonId);
    final lesson = lessonIndex != -1 ? allLessons[lessonIndex] : allLessons.first;

    final title = isAr ? lesson.titleAr : lesson.titleEn;
    final category = isAr ? lesson.categoryAr : lesson.categoryEn;
    final explanation = isAr ? lesson.explanationAr : lesson.explanationEn;
    final workedExample = isAr ? lesson.workedExampleAr : lesson.workedExampleEn;
    final takeaway = isAr ? lesson.takeawayAr : lesson.takeawayEn;
    final quiz = lesson.quiz;
    final question = isAr ? quiz.questionAr : quiz.questionEn;
    final options = isAr ? quiz.optionsAr : quiz.optionsEn;
    final quizExplanation = isAr ? quiz.explanationAr : quiz.explanationEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.academyLesson(lesson.number)),
        actions: [
          if (_isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16),
              child: Chip(
                avatar: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
                label: Text(
                  _quizScore > 0 ? '${l10n.academyCompleted} ($_quizScore%)' : l10n.academyCompleted,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                ),
                backgroundColor: Colors.green.withAlpha(25),
                side: BorderSide.none,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Explanation Card
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.menu_book_rounded, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'الشرح والمفاهيم الأساسية' : 'Core Concept & Explanation',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          explanation,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Worked Real-World Example
                  AppCard(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? 'مثال عملي توضيحي' : 'Worked Practical Example',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          workedExample,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Interactive Tool Card
                  _buildInteractiveTool(context, theme, isAr, lesson),
                  const SizedBox(height: 16),

                  // Practical Takeaway Card
                  AppCard(
                    backgroundColor: theme.colorScheme.primary.withAlpha(20),
                    border: Border.all(color: theme.colorScheme.primary.withAlpha(80)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.bookmark_added_rounded, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.academyTakeaway,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                takeaway,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Knowledge Check / Quiz
                  Text(
                    l10n.academyQuiz,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr
                        ? 'أجب عن السؤال التالي لتثبيت فهمك وإتمام الدرس:'
                        : 'Answer the question below to test your understanding:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(options.length, (index) {
                          final isSelected = _selectedOptionIndex == index;
                          final isCorrect = index == quiz.correctOptionIndex;

                          Color? cardColor;
                          Color? borderColor;
                          IconData? trailingIcon;

                          if (_hasAnswered) {
                            if (isSelected) {
                              if (isCorrect) {
                                cardColor = Colors.green.withAlpha(30);
                                borderColor = Colors.green;
                                trailingIcon = Icons.check_circle_rounded;
                              } else {
                                cardColor = Colors.red.withAlpha(30);
                                borderColor = Colors.red;
                                trailingIcon = Icons.cancel_rounded;
                              }
                            } else if (isCorrect) {
                              cardColor = Colors.green.withAlpha(20);
                              borderColor = Colors.green.withAlpha(80);
                              trailingIcon = Icons.check_circle_outline_rounded;
                            }
                          } else if (isSelected) {
                            cardColor = theme.colorScheme.primary.withAlpha(20);
                            borderColor = theme.colorScheme.primary;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: _hasAnswered
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedOptionIndex = index;
                                        _hasAnswered = true;
                                      });
                                      final earnedScore = isCorrect ? 100 : 50;
                                      _completeLesson(earnedScore);
                                    },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardColor ?? theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: borderColor ?? theme.colorScheme.outline.withAlpha(60),
                                    width: isSelected || (isCorrect && _hasAnswered) ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      backgroundColor: isSelected
                                          ? (isCorrect ? Colors.green : Colors.red)
                                          : theme.colorScheme.outline.withAlpha(40),
                                      foregroundColor: isSelected ? Colors.white : theme.colorScheme.onSurface,
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        options[index],
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    if (trailingIcon != null)
                                      Icon(
                                        trailingIcon,
                                        color: isCorrect ? Colors.green : Colors.red,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        // Quiz Feedback / Explanation Card
                        if (_hasAnswered) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_selectedOptionIndex == quiz.correctOptionIndex)
                                  ? Colors.green.withAlpha(20)
                                  : Colors.orange.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: (_selectedOptionIndex == quiz.correctOptionIndex)
                                    ? Colors.green.withAlpha(80)
                                    : Colors.orange.withAlpha(80),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      (_selectedOptionIndex == quiz.correctOptionIndex)
                                          ? Icons.celebration_rounded
                                          : Icons.info_outline_rounded,
                                      color: (_selectedOptionIndex == quiz.correctOptionIndex)
                                          ? Colors.green
                                          : Colors.orange.shade800,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      (_selectedOptionIndex == quiz.correctOptionIndex)
                                          ? (isAr ? 'إجابة صحيحة وممتازة!' : 'Correct! Great job!')
                                          : (isAr ? 'ليست الإجابة الدقيقة تماماً' : 'Not quite right'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: (_selectedOptionIndex == quiz.correctOptionIndex)
                                            ? Colors.green
                                            : Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  quizExplanation,
                                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _hasAnswered = false;
                                  _selectedOptionIndex = null;
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(isAr ? 'إعادة المحاولة' : 'Try Again'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bottom Navigation: Next Lesson / Back to Academy
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: Text(l10n.commonBack),
                        ),
                      ),
                      if (lessonIndex < allLessons.length - 1) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final nextLesson = allLessons[lessonIndex + 1];
                              context.pushReplacement('/nutrition/academy/lesson/${nextLesson.id}');
                            },
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: Text(isAr ? 'الدرس التالي' : 'Next Lesson'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInteractiveTool(
    BuildContext context,
    ThemeData theme,
    bool isAr,
    AcademyLesson lesson,
  ) {
    // Lesson 2: BMR & TDEE Explorer
    if (lesson.id == 'lesson_2_bmr_vs_tdee' ||
        lesson.id == 'lesson_4_deficits' ||
        lesson.id == 'lesson_5_surplus') {
      final tdee = _toolBmr * _toolActivityFactor;
      final target = tdee + _toolGoalDelta;

      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'مستكشف الطاقة التفاعلي (BMR & TDEE)' : 'Interactive Energy Explorer',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? 'حرّك المؤشرات لتشاهد مباشرة كيف يؤثر معامل النشاط والهدف على سعراتك اليومية:'
                  : 'Adjust sliders to see live how activity and deficit/surplus shape your daily intake:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // BMR Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isAr ? 'معدل الأيض (BMR)' : 'Base Metabolism (BMR)'),
                Text(
                  '${_toolBmr.toInt()} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _toolBmr,
              min: 1200,
              max: 2400,
              divisions: 24,
              label: '${_toolBmr.toInt()}',
              onChanged: (val) => setState(() => _toolBmr = val),
            ),

            // Activity Factor
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isAr ? 'معامل النشاط' : 'Activity Factor'),
                Text(
                  '${_toolActivityFactor}x',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Slider(
              value: _toolActivityFactor,
              min: 1.2,
              max: 1.9,
              divisions: 7,
              label: '${_toolActivityFactor}x',
              onChanged: (val) => setState(() => _toolActivityFactor = (val * 100).round() / 100),
            ),

            // Deficit / Surplus Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isAr ? 'تعديل الهدف (عجز / فائض)' : 'Goal Offset (Deficit / Surplus)'),
                Text(
                  '${_toolGoalDelta > 0 ? '+' : ''}${_toolGoalDelta.toInt()} kcal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _toolGoalDelta > 0
                        ? Colors.blue
                        : _toolGoalDelta < 0
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              ],
            ),
            Slider(
              value: _toolGoalDelta,
              min: -750,
              max: 750,
              divisions: 15,
              label: '${_toolGoalDelta.toInt()}',
              onChanged: (val) => setState(() => _toolGoalDelta = val),
            ),

            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _MiniStat(label: 'BMR', value: '${_toolBmr.toInt()} kcal'),
                _MiniStat(label: 'TDEE', value: '${tdee.toInt()} kcal'),
                _MiniStat(
                  label: isAr ? 'الهدف المقترح' : 'Target',
                  value: '${target.toInt()} kcal',
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/nutrition/calculator'),
                icon: const Icon(Icons.calculate_rounded, size: 16),
                label: Text(isAr ? 'فتح الحاسبة الكاملة للجسم' : 'Open Full Personal Calculator'),
              ),
            ),
          ],
        ),
      );
    }

    // Lessons 7, 8, 9, 10, 11, 12, 13: Portion Gram Scaler
    if (lesson.id == 'lesson_7_food_labels' ||
        lesson.id == 'lesson_8_raw_vs_cooked' ||
        lesson.id == 'lesson_9_portion_sizes' ||
        lesson.id == 'lesson_10_liquid_calories' ||
        lesson.id == 'lesson_11_cooking_oils') {
      final scaledCalories = (_toolBaseCaloriesPer100g * _toolGrams) / 100.0;

      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.scale_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  isAr ? 'حاسبة الحصص بالغرام (المعادلة الحية)' : 'Live Portion Weight Scaler',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isAr
                  ? 'المعادلة الأساسية: (القيمة لكل 100غ × وزن الحصة بالغرام) ÷ 100'
                  : 'Core Formula: (Nutrient per 100g × Grams) ÷ 100',
              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary, fontSize: 13),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isAr ? 'وزن الحصة المسجلة' : 'Portion Grams:'),
                Text(
                  '${_toolGrams.toInt()} g',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                ),
              ],
            ),
            Slider(
              value: _toolGrams,
              min: 20,
              max: 400,
              divisions: 38,
              label: '${_toolGrams.toInt()}g',
              onChanged: (val) => setState(() => _toolGrams = val),
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'القيمة المرجعية (لكل 100غ):' : 'Reference per 100g:'),
                      Text('${_toolBaseCaloriesPer100g.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'الناتج للحصة الفعلية (${_toolGrams.toInt()}غ):' : 'Actual for ${_toolGrams.toInt()}g:'),
                      Text(
                        '${scaledCalories.round()} kcal',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => context.push('/nutrition/food-calculator'),
                icon: const Icon(Icons.calculate_outlined, size: 16),
                label: Text(isAr ? 'تجربة الحاسبة الذكية للأطعمة' : 'Launch Smart Food Calculator'),
              ),
            ),
          ],
        ),
      );
    }

    // Default / Macro Lessons (1, 3, 6, 14): Interactive 4-4-9 Macro Explorer
    final totalCalories = (_toolProtein * 4) + (_toolCarbs * 4) + (_toolFat * 9);
    final pPct = totalCalories > 0 ? (_toolProtein * 4 / totalCalories) * 100 : 0.0;
    final cPct = totalCalories > 0 ? (_toolCarbs * 4 / totalCalories) * 100 : 0.0;
    final fPct = totalCalories > 0 ? (_toolFat * 9 / totalCalories) * 100 : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                isAr ? 'حاسبة قاعدة السعرات (4 - 4 - 9)' : 'Interactive 4-4-9 Macro Calculator',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'البروتين: 4 سعرة/غ | الكربوهيدرات: 4 سعرة/غ | الدهون: 9 سعرة/غ'
                : 'Protein: 4 kcal/g | Carbs: 4 kcal/g | Fat: 9 kcal/g',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          // Protein Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.protein, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(isAr ? 'بروتين (غ)' : 'Protein (g)'),
                ],
              ),
              Text(
                '${_toolProtein.toInt()}g (${(_toolProtein * 4).toInt()} kcal)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _toolProtein,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.protein,
            onChanged: (val) => setState(() => _toolProtein = val),
          ),

          // Carbs Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.carbs, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(isAr ? 'كربوهيدرات (غ)' : 'Carbs (g)'),
                ],
              ),
              Text(
                '${_toolCarbs.toInt()}g (${(_toolCarbs * 4).toInt()} kcal)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _toolCarbs,
            min: 0,
            max: 150,
            divisions: 30,
            activeColor: AppColors.carbs,
            onChanged: (val) => setState(() => _toolCarbs = val),
          ),

          // Fat Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.fat, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(isAr ? 'دهون (غ)' : 'Fat (g)'),
                ],
              ),
              Text(
                '${_toolFat.toInt()}g (${(_toolFat * 9).toInt()} kcal)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Slider(
            value: _toolFat,
            min: 0,
            max: 50,
            divisions: 25,
            activeColor: AppColors.fat,
            onChanged: (val) => setState(() => _toolFat = val),
          ),

          // Total Bar
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (pPct > 0)
                    Expanded(
                      flex: (pPct * 10).toInt(),
                      child: Container(color: AppColors.protein),
                    ),
                  if (cPct > 0)
                    Expanded(
                      flex: (cPct * 10).toInt(),
                      child: Container(color: AppColors.carbs),
                    ),
                  if (fPct > 0)
                    Expanded(
                      flex: (fPct * 10).toInt(),
                      child: Container(color: AppColors.fat),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'إجمالي السعرات المحسوبة:' : 'Calculated Energy:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${totalCalories.toInt()} kcal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _MiniStat({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
          ),
        ),
      ],
    );
  }
}
