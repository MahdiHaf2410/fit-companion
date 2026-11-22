import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_colors.dart';
import '../theme/app_palettes.dart';

/// Shared clock + touch state for the animated backgrounds.
///
/// One instance lives at the app root ([BackgroundHost]); every page paints its
/// own background from it, so the animation never "jumps" between screens.
class BackgroundController extends ChangeNotifier {
  double time = 0; // seconds
  Offset? touch; // last pointer position (global)
  double touchStrength = 0; // 1 when touching, fades to 0
  final List<(Offset, double)> ripples = []; // (position, start time)

  void _tick(double t, double dt) {
    time = t;
    if (touch != null && touchStrength > 0) {
      touchStrength = math.max(0, touchStrength - dt * 0.9);
    }
    ripples.removeWhere((r) => t - r.$2 > 1.1);
    notifyListeners();
  }

  void _down(Offset p) {
    touch = p;
    touchStrength = 1;
    ripples.add((p, time));
    if (ripples.length > 6) ripples.removeAt(0);
  }

  void _move(Offset p) {
    touch = p;
    touchStrength = 1;
  }
}

class _BackgroundScope extends InheritedWidget {
  final BackgroundController controller;
  final BackgroundEffect effect;
  final bool enabled;
  final bool interactive;
  final double intensity;

  const _BackgroundScope({
    required this.controller,
    required this.effect,
    required this.enabled,
    required this.interactive,
    required this.intensity,
    required super.child,
  });

  @override
  bool updateShouldNotify(_BackgroundScope old) =>
      old.effect != effect || old.enabled != enabled || old.interactive != interactive || old.intensity != intensity;
}

/// Placed once in MaterialApp.builder: runs the clock (≈30 fps) and listens to
/// touches anywhere on screen without blocking them.
class BackgroundHost extends StatefulWidget {
  final bool enabled;
  final BackgroundEffect effect;
  final bool interactive;
  final double intensity;
  final Widget child;

  const BackgroundHost({
    super.key,
    required this.enabled,
    required this.effect,
    required this.interactive,
    required this.intensity,
    required this.child,
  });

  @override
  State<BackgroundHost> createState() => _BackgroundHostState();
}

class _BackgroundHostState extends State<BackgroundHost> with SingleTickerProviderStateMixin {
  final _controller = BackgroundController();
  late final Ticker _ticker = createTicker(_onTick);
  double _lastEmit = 0;
  double _base = 0; // controller time when the ticker (re)started

  @override
  void didUpdateWidget(covariant BackgroundHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    // Respect the system "remove animations" accessibility setting.
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldRun = widget.enabled && widget.effect != BackgroundEffect.none && !reduceMotion;
    if (shouldRun && !_ticker.isActive) {
      _base = _controller.time;
      _lastEmit = _base;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6 + _base;
    // ~30 fps is plenty for ambient motion and halves the GPU/battery cost.
    if (t - _lastEmit < 1 / 30) return;
    final dt = t - _lastEmit;
    _lastEmit = t;
    _controller._tick(t, dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = _BackgroundScope(
      controller: _controller,
      effect: widget.effect,
      enabled: widget.enabled,
      interactive: widget.interactive,
      intensity: widget.intensity,
      child: widget.child,
    );
    if (!widget.enabled || !widget.interactive) return scope;
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _controller._down(e.position),
      onPointerMove: (e) => _controller._move(e.position),
      child: scope,
    );
  }
}

/// Paints the animated background behind one page (used by the page transitions).
class PageBackground extends StatelessWidget {
  final Widget child;
  const PageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_BackgroundScope>();
    if (scope == null || !scope.enabled) return child;
    final theme = Theme.of(context);
    final palette = context.palette;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: BackgroundPainter(
              controller: scope.controller,
              palette: palette,
              brightness: theme.brightness,
              effect: scope.effect,
              intensity: scope.intensity,
              interactive: scope.interactive,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Wraps any page transition so every route gets its own painted background
/// (pages stay visually separate during transitions).
class BackgroundPageTransitionsBuilder extends PageTransitionsBuilder {
  final PageTransitionsBuilder inner;
  const BackgroundPageTransitionsBuilder(this.inner);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return inner.buildTransitions(route, context, animation, secondaryAnimation, PageBackground(child: child));
  }
}

// =============================================================================
// Painter
// =============================================================================

class BackgroundPainter extends CustomPainter {
  final BackgroundController controller;
  final AppPalette palette;
  final Brightness brightness;
  final BackgroundEffect effect;
  final double intensity;
  final bool interactive;

  BackgroundPainter({
    required this.controller,
    required this.palette,
    required this.brightness,
    required this.effect,
    required this.intensity,
    required this.interactive,
  }) : super(repaint: controller);

  bool get _dark => brightness == Brightness.dark;
  Color get _bg => _dark ? palette.bgDark : palette.bgLight;
  Color get _a => palette.primary(brightness);
  Color get _b => palette.secondary;
  Color get _c => palette.tertiary;

  /// Base opacity of decorative elements (lighter on light backgrounds).
  double get _alpha => (_dark ? 0.32 : 0.2) * intensity;

  static final _rng = math.Random(7);
  static final _seeds = List.generate(90, (_) => [for (int i = 0; i < 6; i++) _rng.nextDouble()]);

  Offset? _localTouch(Size size) {
    if (!interactive || controller.touch == null || controller.touchStrength <= 0) return null;
    return controller.touch; // the background fills the page, global ≈ local
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _bg);
    final t = controller.time;
    switch (effect) {
      case BackgroundEffect.none:
        break;
      case BackgroundEffect.orbs:
        _orbs(canvas, size, t);
      case BackgroundEffect.particles:
        _particles(canvas, size, t);
      case BackgroundEffect.waves:
        _waves(canvas, size, t);
      case BackgroundEffect.grid:
        _grid(canvas, size, t);
      case BackgroundEffect.aurora:
        _aurora(canvas, size, t);
      case BackgroundEffect.bokeh:
        _bokeh(canvas, size, t);
      case BackgroundEffect.stars:
        _stars(canvas, size, t);
    }
    if (interactive) _ripples(canvas, t);
  }

  // ---------------------------------------------------------------- effects
  void _glow(Canvas canvas, Offset c, double r, Color color, double a) {
    final shader = RadialGradient(colors: [color.withValues(alpha: a), color.withValues(alpha: 0)])
        .createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, Paint()..shader = shader);
  }

  void _orbs(Canvas canvas, Size s, double t) {
    final colors = [_a, _b, _c, _a];
    for (int i = 0; i < 4; i++) {
      final sd = _seeds[i];
      final x = s.width * (0.5 + 0.42 * math.sin(t * (0.07 + sd[0] * 0.05) + sd[1] * 6.28));
      final y = s.height * (0.5 + 0.42 * math.cos(t * (0.05 + sd[2] * 0.05) + sd[3] * 6.28));
      _glow(canvas, Offset(x, y), s.shortestSide * (0.45 + sd[4] * 0.35), colors[i], _alpha * 0.9);
    }
    final touch = _localTouch(s);
    if (touch != null) _glow(canvas, touch, s.shortestSide * 0.35, _a, _alpha * controller.touchStrength);
  }

  void _particles(Canvas canvas, Size s, double t) {
    const n = 42;
    final pts = <Offset>[];
    final touch = _localTouch(s);
    for (int i = 0; i < n; i++) {
      final sd = _seeds[i];
      var p = Offset(
        ((sd[0] * s.width + t * (sd[2] - 0.5) * 22) % s.width + s.width) % s.width,
        ((sd[1] * s.height + t * (sd[3] - 0.5) * 22) % s.height + s.height) % s.height,
      );
      if (touch != null) {
        // Particles are gently pushed away from the finger
        final d = p - touch;
        final dist = d.distance;
        if (dist < 140 && dist > 0) p += d / dist * (140 - dist) * 0.35 * controller.touchStrength;
      }
      pts.add(p);
    }
    final line = Paint()..strokeWidth = 1;
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        final d = (pts[i] - pts[j]).distance;
        if (d < 95) {
          line.color = _a.withValues(alpha: _alpha * 0.6 * (1 - d / 95));
          canvas.drawLine(pts[i], pts[j], line);
        }
      }
      if (touch != null) {
        final d = (pts[i] - touch).distance;
        if (d < 170) {
          line.color = _b.withValues(alpha: _alpha * 1.4 * (1 - d / 170) * controller.touchStrength);
          canvas.drawLine(pts[i], touch, line);
        }
      }
    }
    final dot = Paint();
    for (int i = 0; i < n; i++) {
      dot.color = (i % 3 == 0 ? _b : _a).withValues(alpha: (_alpha * 2.2).clamp(0, 1));
      canvas.drawCircle(pts[i], 1.6 + _seeds[i][4] * 1.8, dot);
    }
  }

  void _waves(Canvas canvas, Size s, double t) {
    final touch = _localTouch(s);
    final colors = [_c, _b, _a];
    for (int k = 0; k < 3; k++) {
      final base = s.height * (0.68 + k * 0.09);
      final amp = 14.0 + k * 6;
      final path = Path()..moveTo(0, s.height);
      for (double x = 0; x <= s.width + 8; x += 8) {
        var y = base + math.sin(x / s.width * math.pi * (2 + k * 0.6) + t * (0.6 + k * 0.25)) * amp;
        if (touch != null) {
          final dx = (x - touch.dx).abs();
          if (dx < 120) y -= (1 - dx / 120) * 26 * controller.touchStrength;
        }
        path.lineTo(x, y);
      }
      path
        ..lineTo(s.width, s.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[k].withValues(alpha: _alpha * 0.9), colors[k].withValues(alpha: _alpha * 0.15)],
          ).createShader(Rect.fromLTWH(0, base - amp, s.width, s.height - base + amp)),
      );
    }
    _glow(canvas, Offset(s.width * (0.5 + 0.3 * math.sin(t * 0.1)), s.height * 0.18), s.width * 0.6, _a, _alpha * 0.45);
  }

  void _grid(Canvas canvas, Size s, double t) {
    const gap = 26.0;
    final touch = _localTouch(s);
    final scanY = (t * 60) % (s.height + 200) - 100;
    final dot = Paint();
    for (double y = gap / 2; y < s.height; y += gap) {
      for (double x = gap / 2; x < s.width; x += gap) {
        var a = _alpha * 0.45;
        final sy = (y - scanY).abs();
        if (sy < 70) a += _alpha * 1.3 * (1 - sy / 70);
        var r = 1.1;
        if (touch != null) {
          final d = (Offset(x, y) - touch).distance;
          if (d < 130) {
            a += _alpha * 2 * (1 - d / 130) * controller.touchStrength;
            r += 1.6 * (1 - d / 130) * controller.touchStrength;
          }
        }
        dot.color = _a.withValues(alpha: a.clamp(0, 1));
        canvas.drawCircle(Offset(x, y), r, dot);
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 60, s.width, 120),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_b.withValues(alpha: 0), _b.withValues(alpha: _alpha * 0.35), _b.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, scanY - 60, s.width, 120)),
    );
  }

  void _aurora(Canvas canvas, Size s, double t) {
    final colors = [_a, _b, _c];
    final touch = _localTouch(s);
    for (int k = 0; k < 3; k++) {
      final top = s.height * (0.08 + k * 0.12);
      final path = Path()..moveTo(0, top);
      for (double x = 0; x <= s.width + 10; x += 10) {
        var y = top +
            math.sin(x / s.width * math.pi * 1.6 + t * (0.25 + k * 0.08) + k) * 38 +
            math.sin(x / s.width * math.pi * 3.3 - t * 0.17) * 14;
        if (touch != null) {
          final dx = (x - touch.dx).abs();
          if (dx < 150) y += (1 - dx / 150) * 30 * controller.touchStrength;
        }
        path.lineTo(x, y);
      }
      final h = s.height * 0.42;
      for (double x = s.width; x >= -10; x -= 10) {
        path.lineTo(x, top + h + math.sin(x / s.width * math.pi * 1.2 - t * 0.2 + k) * 50);
      }
      path.close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors[k].withValues(alpha: _alpha * 0.85), colors[k].withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, top - 40, s.width, h + 90)),
      );
    }
  }

  void _bokeh(Canvas canvas, Size s, double t) {
    final colors = [_a, _b, _c];
    for (int i = 0; i < 22; i++) {
      final sd = _seeds[i + 10];
      final speed = 8 + sd[2] * 18;
      final r = 14 + sd[3] * 46;
      final y = s.height + r - ((t * speed + sd[1] * (s.height + 2 * r)) % (s.height + 2 * r));
      final x = sd[0] * s.width + math.sin(t * 0.3 + sd[4] * 6) * 18;
      final c = colors[i % 3];
      canvas.drawCircle(Offset(x, y), r, Paint()..color = c.withValues(alpha: _alpha * (0.25 + sd[5] * 0.35)));
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = c.withValues(alpha: _alpha * 0.7),
      );
    }
    final touch = _localTouch(s);
    if (touch != null) _glow(canvas, touch, 120, _b, _alpha * controller.touchStrength);
  }

  void _stars(Canvas canvas, Size s, double t) {
    final p = Paint();
    for (int i = 0; i < 80; i++) {
      final sd = _seeds[i];
      final tw = 0.5 + 0.5 * math.sin(t * (0.8 + sd[2] * 2) + sd[3] * 6.28);
      p.color = (i % 7 == 0 ? _a : (_dark ? Colors.white : palette.textLight))
          .withValues(alpha: (_alpha * (0.6 + 1.6 * tw)).clamp(0, 1));
      canvas.drawCircle(Offset(sd[0] * s.width, sd[1] * s.height), 0.6 + sd[4] * 1.4, p);
    }
    // Occasional shooting star (every ~7 s)
    final phase = t % 7;
    if (phase < 0.9) {
      final k = phase / 0.9;
      final seed = _seeds[((t / 7).floor() * 13) % 80];
      final start = Offset(seed[0] * s.width, seed[1] * s.height * 0.5);
      final head = start + Offset(220 * k, 120 * k);
      canvas.drawLine(
        start + Offset(220 * (k - 0.25).clamp(0, 1), 120 * (k - 0.25).clamp(0, 1)),
        head,
        Paint()
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(colors: [_a.withValues(alpha: 0), _a.withValues(alpha: (_alpha * 3).clamp(0, 1))])
              .createShader(Rect.fromPoints(start, head)),
      );
    }
    _glow(canvas, Offset(s.width * 0.85, s.height * 0.12), s.width * 0.5, _b, _alpha * 0.35);
    final touch = _localTouch(s);
    if (touch != null) _glow(canvas, touch, 110, _a, _alpha * 0.9 * controller.touchStrength);
  }

  void _ripples(Canvas canvas, double t) {
    for (final (pos, start) in controller.ripples) {
      final k = ((t - start) / 1.1).clamp(0.0, 1.0);
      canvas.drawCircle(
        pos,
        12 + 110 * Curves.easeOut.transform(k),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2 * (1 - k)
          ..color = _a.withValues(alpha: (_alpha * 2.4 * (1 - k)).clamp(0, 1)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter old) =>
      old.palette != palette || old.brightness != brightness || old.effect != effect || old.intensity != intensity;
}

/// Small static preview used by the theme picker (no ticker).
class BackgroundPreview extends StatelessWidget {
  final AppPalette palette;
  final Brightness brightness;
  final BackgroundEffect effect;
  final double time;

  const BackgroundPreview({super.key, required this.palette, required this.brightness, required this.effect, this.time = 12});

  @override
  Widget build(BuildContext context) {
    final c = BackgroundController()..time = time;
    return CustomPaint(
      painter: BackgroundPainter(
        controller: c,
        palette: palette,
        brightness: brightness,
        effect: effect,
        intensity: 0.9,
        interactive: false,
      ),
    );
  }
}

/// Effect used for a palette given the user's choice ('auto' = palette default).
BackgroundEffect resolveEffect(AppPalette palette, String choice) {
  if (choice == 'auto') return palette.effect;
  return BackgroundEffect.values.firstWhere((e) => e.name == choice, orElse: () => palette.effect);
}
