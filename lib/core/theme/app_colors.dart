import 'package:flutter/material.dart';

import 'app_palettes.dart';

/// Design tokens.
///
/// - Semantic colours (macros, water, success/error…) are fixed so data keeps the
///   same meaning in every theme.
/// - Brand colours (lime/violet/cyan + gradients) follow the ACTIVE theme
///   palette ([active] is set by the app when the user picks a theme).
class AppColors {
  AppColors._();

  /// Currently selected palette (updated from app.dart).
  static AppPalette active = AppPalettes.neon;

  // Brand (theme-dependent). Names kept for compatibility with existing code.
  static Color get lime => active.accent; // primary accent
  static Color get violet => active.secondary; // secondary accent
  static Color get cyan => active.tertiary; // tertiary accent
  static const Color flame = Color(0xFFFF7A3D); // streaks / energy

  // Neutrals of the active palette
  static Color get darkBackground => active.bgDark;
  static Color get darkCard => active.cardDark;
  static Color get darkCardHigh => active.cardHighDark;
  static Color get darkBorder => active.borderDark;
  static Color get darkSurfaceVariant => active.surfaceVariantDark;
  static Color get darkTextPrimary => active.textDark;
  static Color get darkTextSecondary => active.textSecondaryDark;
  static Color get lightBackground => active.bgLight;
  static Color get lightCard => active.cardLight;
  static Color get lightCardHigh => active.cardHighLight;
  static Color get lightBorder => active.borderLight;
  static Color get lightSurfaceVariant => active.surfaceVariantLight;
  static Color get lightTextPrimary => active.textLight;
  static Color get lightTextSecondary => active.textSecondaryLight;
  static Color get darkPrimary => active.accent;
  static Color get lightPrimary => active.accentLight;

  /// Readable colour on top of an accent-coloured surface.
  static Color get onAccent => active.onColor(active.accent);

  /// Readable colour on top of the secondary gradient (white on dark violet, black on yellow…).
  static Color get onSecondary => active.onColor(active.secondary);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFF4D5E);
  static const Color info = Color(0xFF3B82F6);

  // Nutrition macros
  static const Color protein = Color(0xFF4C9DFF); // blue
  static const Color carbs = Color(0xFFFFB547); // amber
  static const Color fat = Color(0xFFFF5C8A); // rose
  static const Color water = Color(0xFF38BDF8); // sky

  // Gradients
  static LinearGradient get limeGradient => active.accentGradient;
  static LinearGradient get violetGradient => active.secondaryGradient;
  static LinearGradient get heroDark => active.hero(Brightness.dark);
  static LinearGradient get heroLight => active.hero(Brightness.light);
  static const LinearGradient flameGradient = LinearGradient(colors: [Color(0xFFFFB36B), Color(0xFFFF5A36)]);
  static const LinearGradient waterGradient = LinearGradient(colors: [Color(0xFF7DD3FC), Color(0xFF0EA5E9)]);
}

/// Theme data that ThemeData itself doesn't carry (palette, shapes, glass mode).
class AppThemeExt extends ThemeExtension<AppThemeExt> {
  final AppPalette palette;
  final bool glass; // translucent cards over the animated background

  const AppThemeExt({required this.palette, this.glass = false});

  @override
  AppThemeExt copyWith({AppPalette? palette, bool? glass}) =>
      AppThemeExt(palette: palette ?? this.palette, glass: glass ?? this.glass);

  @override
  AppThemeExt lerp(covariant AppThemeExt? other, double t) => t < 0.5 ? this : (other ?? this);
}

/// Convenience accessors that resolve the right token for the current theme.
extension AppColorsX on BuildContext {
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Material chevrons already mirror in RTL (matchTextDirection), so "forward" is always chevron_right.
  IconData get forwardChevron => Icons.chevron_right_rounded;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AppThemeExt get themeExt => Theme.of(this).extension<AppThemeExt>() ?? const AppThemeExt(palette: AppPalettes.neon);
  AppPalette get palette => themeExt.palette;
  Color get cardHigh => isDark ? palette.cardHighDark : palette.cardHighLight;
  Color get textSecondary => isDark ? palette.textSecondaryDark : palette.textSecondaryLight;
  Color get borderColor => isDark ? palette.borderDark : palette.borderLight;
  LinearGradient get heroGradient => palette.hero(Theme.of(this).brightness);
  LinearGradient get accentGradient => palette.accentGradient;
  LinearGradient get secondaryGradient => palette.secondaryGradient;
  double get radiusLg => palette.radiusLg;
  double get radiusMd => palette.radiusMd;
  double get radiusSm => palette.radiusSm;
}
