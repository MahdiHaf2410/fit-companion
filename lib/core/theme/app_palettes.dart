import 'package:flutter/material.dart';

/// Corner style of a theme (cards, buttons, inputs, nav bar).
enum ShapeStyle { sharp, soft, rounded, pill }

/// Animated background effects.
enum BackgroundEffect { none, orbs, particles, waves, grid, aurora, bokeh, stars }

/// One selectable theme. Neutrals (background, cards, text, borders) are
/// generated from [hue]/[tint] so every palette works in light AND dark mode.
class AppPalette {
  final String id;
  final String nameEn;
  final String nameAr;
  final Color accent; // primary in dark mode
  final Color? accentLightOverride; // primary in light mode (auto-darkened if null)
  final Color secondary;
  final Color tertiary;
  final double hue; // tint of the neutral greys
  final double tint; // 0 = pure grey, 0.3 = strongly tinted
  final ShapeStyle shape;
  final BackgroundEffect effect; // default animated effect

  const AppPalette({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.accent,
    required this.secondary,
    required this.tertiary,
    required this.hue,
    this.tint = 0.22,
    this.shape = ShapeStyle.rounded,
    this.effect = BackgroundEffect.orbs,
    this.accentLightOverride,
  });

  String name(String locale) => locale == 'ar' ? nameAr : nameEn;

  // ---------------------------------------------------------------- neutrals
  Color _n(double l, {double satScale = 1}) =>
      HSLColor.fromAHSL(1, hue, (tint * satScale).clamp(0, 1), l).toColor();

  Color get bgDark => _n(0.045);
  Color get cardDark => _n(0.085);
  Color get cardHighDark => _n(0.115);
  Color get borderDark => _n(0.17);
  Color get surfaceVariantDark => _n(0.13);
  Color get textDark => _n(0.955, satScale: 0.5);
  Color get textSecondaryDark => _n(0.63, satScale: 0.45);

  Color get bgLight => _n(0.955, satScale: 0.9);
  Color get cardLight => Colors.white;
  Color get cardHighLight => _n(0.975, satScale: 0.7);
  Color get borderLight => _n(0.885, satScale: 0.8);
  Color get surfaceVariantLight => _n(0.925, satScale: 0.8);
  Color get textLight => _n(0.085, satScale: 1.4);
  Color get textSecondaryLight => _n(0.39, satScale: 0.6);

  /// Primary used on white backgrounds: darkened until WCAG AA (4.5:1).
  Color get accentLight {
    if (accentLightOverride != null) return accentLightOverride!;
    var hsl = HSLColor.fromColor(accent);
    for (int i = 0; i < 40 && _contrast(hsl.toColor(), Colors.white) < 4.5; i++) {
      hsl = hsl.withLightness((hsl.lightness - 0.025).clamp(0.0, 1.0));
    }
    return hsl.toColor();
  }

  Color primary(Brightness b) => b == Brightness.dark ? accent : accentLight;

  /// Readable text/icon colour on top of the primary colour.
  Color onPrimary(Brightness b) => onColor(primary(b));

  /// Black or white, whichever is more readable on [c].
  Color onColor(Color c) {
    const ink = Color(0xFF0B0E13);
    return _contrast(ink, c) >= _contrast(Colors.white, c) ? ink : Colors.white;
  }

  // ---------------------------------------------------------------- shapes
  double get radiusLg => switch (shape) { ShapeStyle.sharp => 8, ShapeStyle.soft => 16, ShapeStyle.rounded => 24, ShapeStyle.pill => 30 };
  double get radiusMd => switch (shape) { ShapeStyle.sharp => 6, ShapeStyle.soft => 12, ShapeStyle.rounded => 18, ShapeStyle.pill => 26 };
  double get radiusSm => switch (shape) { ShapeStyle.sharp => 4, ShapeStyle.soft => 10, ShapeStyle.rounded => 12, ShapeStyle.pill => 20 };

  // ---------------------------------------------------------------- gradients
  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_shift(accent, 0.08), _shift(accent, -0.08)],
      );

  LinearGradient get secondaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_shift(secondary, 0.08), _shift(secondary, -0.1)],
      );

  LinearGradient hero(Brightness b) {
    final bg = b == Brightness.dark ? cardDark : cardLight;
    final k = b == Brightness.dark ? 0.86 : 0.9;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.lerp(primary(b), bg, k)!, bg, Color.lerp(secondary, bg, k)!],
    );
  }

  static Color _shift(Color c, double dl) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + dl).clamp(0.0, 1.0)).toColor();
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance(), lb = b.computeLuminance();
    final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}

/// All built-in themes.
class AppPalettes {
  AppPalettes._();

  static const neon = AppPalette(
    id: 'neon', nameEn: 'Neon Athletic', nameAr: 'نيون رياضي',
    accent: Color(0xFFC6FF3D), accentLightOverride: Color(0xFF4A7C00), secondary: Color(0xFF6A4BFF), tertiary: Color(0xFF22D3EE),
    hue: 215, tint: 0.28, shape: ShapeStyle.rounded, effect: BackgroundEffect.orbs,
  );

  static const all = <AppPalette>[
    neon,
    AppPalette(
      id: 'ocean', nameEn: 'Ocean Pulse', nameAr: 'نبض المحيط',
      accent: Color(0xFF22D3EE), secondary: Color(0xFF3B82F6), tertiary: Color(0xFF34D399),
      hue: 205, tint: 0.35, shape: ShapeStyle.soft, effect: BackgroundEffect.waves,
    ),
    AppPalette(
      id: 'crimson', nameEn: 'Crimson Power', nameAr: 'قوة القرمزي',
      accent: Color(0xFFFF3B5C), secondary: Color(0xFFFF9F1C), tertiary: Color(0xFFFFD166),
      hue: 350, tint: 0.18, shape: ShapeStyle.sharp, effect: BackgroundEffect.particles,
    ),
    AppPalette(
      id: 'royal', nameEn: 'Royal Purple', nameAr: 'البنفسجي الملكي',
      accent: Color(0xFFB388FF), secondary: Color(0xFFFF5CA8), tertiary: Color(0xFF7DD3FC),
      hue: 265, tint: 0.3, shape: ShapeStyle.pill, effect: BackgroundEffect.aurora,
    ),
    AppPalette(
      id: 'sunset', nameEn: 'Sunset Blaze', nameAr: 'لهيب الغروب',
      accent: Color(0xFFFF8A3D), secondary: Color(0xFFFF4D8D), tertiary: Color(0xFFFFD23F),
      hue: 15, tint: 0.25, shape: ShapeStyle.rounded, effect: BackgroundEffect.bokeh,
    ),
    AppPalette(
      id: 'emerald', nameEn: 'Emerald Forest', nameAr: 'الغابة الزمردية',
      accent: Color(0xFF2EE59D), secondary: Color(0xFF14B8A6), tertiary: Color(0xFFA3E635),
      hue: 160, tint: 0.28, shape: ShapeStyle.soft, effect: BackgroundEffect.orbs,
    ),
    AppPalette(
      id: 'arctic', nameEn: 'Arctic Ice', nameAr: 'جليد القطب',
      accent: Color(0xFF8BE9FF), secondary: Color(0xFFA5B4FC), tertiary: Color(0xFFE0F2FE),
      hue: 200, tint: 0.3, shape: ShapeStyle.pill, effect: BackgroundEffect.stars,
    ),
    AppPalette(
      id: 'gold', nameEn: 'Black Gold', nameAr: 'الذهب الأسود',
      accent: Color(0xFFF5C451), secondary: Color(0xFFD4A373), tertiary: Color(0xFFFFE8A3),
      hue: 40, tint: 0.08, shape: ShapeStyle.sharp, effect: BackgroundEffect.particles,
    ),
    AppPalette(
      id: 'cyber', nameEn: 'Cyberpunk', nameAr: 'سايبربانك',
      accent: Color(0xFFFF2BD6), secondary: Color(0xFFFFE600), tertiary: Color(0xFF00F0FF),
      hue: 250, tint: 0.4, shape: ShapeStyle.sharp, effect: BackgroundEffect.grid,
    ),
    AppPalette(
      id: 'sakura', nameEn: 'Sakura Bloom', nameAr: 'زهر الساكورا',
      accent: Color(0xFFFF8FB8), secondary: Color(0xFFC084FC), tertiary: Color(0xFFFDE68A),
      hue: 335, tint: 0.22, shape: ShapeStyle.pill, effect: BackgroundEffect.bokeh,
    ),
    AppPalette(
      id: 'mono', nameEn: 'Midnight Mono', nameAr: 'منتصف الليل',
      accent: Color(0xFFF2F2F2), accentLightOverride: Color(0xFF111111), secondary: Color(0xFF9CA3AF), tertiary: Color(0xFF6B7280),
      hue: 0, tint: 0, shape: ShapeStyle.sharp, effect: BackgroundEffect.stars,
    ),
    AppPalette(
      id: 'sahara', nameEn: 'Sahara Sand', nameAr: 'رمال الصحراء',
      accent: Color(0xFFE9B872), secondary: Color(0xFFD9734E), tertiary: Color(0xFF8FB996),
      hue: 30, tint: 0.2, shape: ShapeStyle.soft, effect: BackgroundEffect.waves,
    ),
    AppPalette(
      id: 'toxic', nameEn: 'Toxic Lime', nameAr: 'الأخضر السام',
      accent: Color(0xFF9DFF00), secondary: Color(0xFF00FFA3), tertiary: Color(0xFFFFF500),
      hue: 100, tint: 0.15, shape: ShapeStyle.sharp, effect: BackgroundEffect.grid,
    ),
    AppPalette(
      id: 'aurora', nameEn: 'Northern Aurora', nameAr: 'الشفق القطبي',
      accent: Color(0xFF5EEAD4), secondary: Color(0xFFA78BFA), tertiary: Color(0xFF86EFAC),
      hue: 190, tint: 0.32, shape: ShapeStyle.rounded, effect: BackgroundEffect.aurora,
    ),
    AppPalette(
      id: 'lava', nameEn: 'Molten Lava', nameAr: 'الحمم البركانية',
      accent: Color(0xFFFF5A1F), secondary: Color(0xFFFFB020), tertiary: Color(0xFFFF2D55),
      hue: 10, tint: 0.3, shape: ShapeStyle.rounded, effect: BackgroundEffect.particles,
    ),
    AppPalette(
      id: 'algeria', nameEn: 'Algeria', nameAr: 'الجزائر',
      accent: Color(0xFF00B36B), secondary: Color(0xFFE8112D), tertiary: Color(0xFFF5F5F5),
      hue: 150, tint: 0.2, shape: ShapeStyle.rounded, effect: BackgroundEffect.stars,
    ),
    AppPalette(
      id: 'coffee', nameEn: 'Espresso', nameAr: 'إسبريسو',
      accent: Color(0xFFD7A77A), secondary: Color(0xFFB07D62), tertiary: Color(0xFFEDE0D4),
      hue: 25, tint: 0.25, shape: ShapeStyle.soft, effect: BackgroundEffect.bokeh,
    ),
    AppPalette(
      id: 'electric', nameEn: 'Electric Blue', nameAr: 'الأزرق الكهربائي',
      accent: Color(0xFF3D8BFF), secondary: Color(0xFF00E5FF), tertiary: Color(0xFFB4FF39),
      hue: 222, tint: 0.4, shape: ShapeStyle.soft, effect: BackgroundEffect.particles,
    ),
    AppPalette(
      id: 'rose_gold', nameEn: 'Rose Gold', nameAr: 'الذهبي الوردي',
      accent: Color(0xFFF4A6A0), secondary: Color(0xFFE8C07D), tertiary: Color(0xFFFFD6E0),
      hue: 10, tint: 0.14, shape: ShapeStyle.pill, effect: BackgroundEffect.orbs,
    ),
    AppPalette(
      id: 'matrix', nameEn: 'Matrix', nameAr: 'ماتريكس',
      accent: Color(0xFF00FF66), secondary: Color(0xFF00C853), tertiary: Color(0xFF69F0AE),
      hue: 140, tint: 0.35, shape: ShapeStyle.sharp, effect: BackgroundEffect.grid,
    ),
  ];

  static AppPalette byId(String? id) => all.firstWhere((p) => p.id == id, orElse: () => neon);
}
