import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Base surface of the app. Supports an optional gradient, tap feedback
/// (scale + haptic) and a highlighted "accent" border.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  /// Corner radius; null = the active theme's shape (sharp / soft / rounded / pill).
  final double? radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = this.radius ?? context.radiusLg;
    // Glass cards over the animated background: slightly translucent.
    final glass = context.themeExt.glass && backgroundColor == null;
    final cardColor = backgroundColor ?? theme.colorScheme.surface.withValues(alpha: glass ? (context.isDark ? 0.82 : 0.86) : 1);

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? cardColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ??
            Border.all(
              color: context.borderColor.withAlpha(context.isDark ? 170 : 255),
              width: 1,
            ),
        boxShadow: context.isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0D1320).withAlpha(10),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      // Transparent Material so ListTiles/InkWells inside the card paint their
      // ripples on top of the card background (not hidden behind it).
      child: Material(type: MaterialType.transparency, child: child),
    );

    if (onTap == null && onLongPress == null) return content;

    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(radius),
      child: content,
    );
  }
}

/// Adds a subtle "press down" scale animation, ink ripple and haptic tick.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius borderRadius;
  final double pressedScale;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.pressedScale = 0.97,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? widget.pressedScale : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTapDown: (_) => _set(true),
          onTapCancel: () => _set(false),
          onTapUp: (_) => _set(false),
          onTap: widget.onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                },
          onLongPress: widget.onLongPress,
          child: widget.child,
        ),
      ),
    );
  }
}
