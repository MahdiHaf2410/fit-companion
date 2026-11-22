import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

/// Animated circular progress ring with a rounded cap and optional gradient.
class ProgressRing extends StatelessWidget {
  final double progress; // 0..1 (values > 1 draw a full ring)
  final double size;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final Color? trackColor;
  final Widget? child;
  final Duration duration;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    required this.color,
    this.gradient,
    this.trackColor,
    this.child,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    final track = trackColor ?? color.withAlpha(context.isDark ? 38 : 30);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => CustomPaint(
          painter: _RingPainter(
            progress: value,
            strokeWidth: strokeWidth,
            color: color,
            gradient: gradient,
            trackColor: track,
          ),
          child: Center(child: child),
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Gradient? gradient;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.gradient,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    if (gradient != null) {
      paint.shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: (gradient as LinearGradient).colors,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(arcRect);
    } else {
      paint.color = color;
    }
    canvas.drawArc(arcRect, -math.pi / 2, 2 * math.pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color || old.trackColor != trackColor;
}

/// Number that counts up smoothly whenever its value changes.
class AnimatedNumber extends StatelessWidget {
  final double value;
  final int decimals;
  final TextStyle? style;
  final String suffix;

  const AnimatedNumber({
    super.key,
    required this.value,
    this.decimals = 0,
    this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text('${v.toStringAsFixed(decimals)}$suffix', style: style),
    );
  }
}

/// Title row used above every section ("Today's workout   See all >").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.only(top: 22, bottom: 10),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(actionLabel!),
                  const SizedBox(width: 2),
                  Icon(context.forwardChevron, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Rounded square icon with a soft tinted (or gradient) background.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Gradient? gradient;
  final double size;
  final double iconSize;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.gradient,
    this.size = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final onGradient = gradient != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onGradient ? null : color.withAlpha(context.isDark ? 40 : 28),
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, size: iconSize, color: onGradient ? context.palette.onColor(gradient!.colors.first) : color),
    );
  }
}

/// Compact KPI tile: icon, big value, small label.
class StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, size: 34, iconSize: 18),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Small rounded label ("PR", "Active", "+2.5kg").
class Pill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool solid;

  const Pill({super.key, required this.label, required this.color, this.icon, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final fg = solid ? context.palette.onColor(color) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: solid ? color : color.withAlpha(context.isDark ? 38 : 28),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

/// 7-day activity strip (index 0 = six days ago, last = today).
class WeekStrip extends StatelessWidget {
  final List<bool> days;
  final List<String> labels; // 7 short day labels in the same order
  final Color color;

  const WeekStrip({super.key, required this.days, required this.labels, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = days[i];
        final isToday = i == 6;
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300 + i * 60),
                curve: Curves.easeOutBack,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active ? color : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? color : (isToday ? color.withAlpha(160) : context.borderColor),
                    width: isToday && !active ? 2 : 1.4,
                  ),
                ),
                child: active
                    ? Icon(Icons.check_rounded, size: 16, color: context.palette.onColor(color))
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isToday ? theme.colorScheme.onSurface : null,
                  fontWeight: isToday ? FontWeight.w800 : null,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Fades + slides children in, staggered by [index]. Cheap entrance animation.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: child),
      ),
      child: child,
    );
  }
}

/// Short weekday labels for the last 7 days ending today.
List<String> last7DayLabels(String languageCode) {
  const en = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  const ar = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
  final now = DateTime.now();
  return List.generate(7, (i) {
    final d = now.subtract(Duration(days: 6 - i));
    final idx = d.weekday - 1; // Monday = 0
    return languageCode == 'ar' ? ar[idx] : en[idx];
  });
}

/// Bottom padding tab screens must leave so content clears the floating nav bar.
const double kNavBarClearance = 116;
