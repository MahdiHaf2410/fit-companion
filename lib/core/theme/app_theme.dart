import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_palettes.dart';
import '../widgets/animated_background.dart';

class AppTheme {
  AppTheme._();

  /// Default (Neon) themes, kept for tests and callers without a palette.
  static ThemeData get lightTheme => build(Brightness.light, AppPalettes.neon);
  static ThemeData get darkTheme => build(Brightness.dark, AppPalettes.neon);

  /// [animatedBackground]: scaffolds become transparent so the animated
  /// background (painted behind every page) is visible, and cards turn "glass".
  static ThemeData build(Brightness brightness, AppPalette palette, {bool animatedBackground = false}) {
    final isDark = brightness == Brightness.dark;
    final radiusSm = palette.radiusSm;
    final radiusMd = palette.radiusMd;
    final radiusLg = palette.radiusLg;

    final bg = isDark ? palette.bgDark : palette.bgLight;
    final card = isDark ? palette.cardDark : palette.cardLight;
    final cardHigh = isDark ? palette.cardHighDark : palette.cardHighLight;
    final primary = palette.primary(brightness);
    final onPrimary = palette.onPrimary(brightness);
    final textPrimary = isDark ? palette.textDark : palette.textLight;
    final textSecondary = isDark ? palette.textSecondaryDark : palette.textSecondaryLight;
    final border = isDark ? palette.borderDark : palette.borderLight;
    final surfaceVariant = isDark ? palette.surfaceVariantDark : palette.surfaceVariantLight;
    final secondary = palette.secondary;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color.lerp(primary, bg, isDark ? 0.78 : 0.82)!,
      onPrimaryContainer: isDark ? primary : Color.lerp(primary, Colors.black, 0.35)!,
      secondary: secondary,
      onSecondary: palette.onColor(secondary),
      secondaryContainer: Color.lerp(secondary, bg, isDark ? 0.78 : 0.85)!,
      onSecondaryContainer: isDark ? Color.lerp(secondary, Colors.white, 0.5)! : Color.lerp(secondary, Colors.black, 0.45)!,
      tertiary: palette.tertiary,
      onTertiary: palette.onColor(palette.tertiary),
      error: AppColors.error,
      onError: Colors.white,
      surface: card,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: bg,
      surfaceContainerLow: card,
      surfaceContainer: card,
      surfaceContainerHigh: cardHigh,
      surfaceContainerHighest: surfaceVariant,
      outline: border,
      outlineVariant: surfaceVariant,
      shadow: Colors.black,
    );

    final textTheme = TextTheme(
      displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 34, letterSpacing: -1.0, height: 1.05),
      headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 30, letterSpacing: -0.8),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: -0.5),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20, letterSpacing: -0.3),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.2),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 15, height: 1.4),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 13.5, height: 1.4),
      bodySmall: TextStyle(color: textSecondary, fontSize: 12, height: 1.35),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
      labelMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
      labelSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.4),
    );

    OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm + 2),
          borderSide: BorderSide(color: c, width: w),
        );

    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: animatedBackground ? Colors.transparent : bg,
      canvasColor: bg,
      extensions: [AppThemeExt(palette: palette, glass: animatedBackground)],
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: PageTransitionsTheme(
        // With the animated background each page paints its own background
        // layer, so pages stay clean during transitions.
        builders: {
          for (final e in const {
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          }.entries)
            e.key: animatedBackground ? BackgroundPageTransitionsBuilder(e.value) : e.value,
        },
      ),
      appBarTheme: AppBarTheme(
        // Slightly translucent over the animated background
        backgroundColor: animatedBackground ? bg.withAlpha(isDark ? 200 : 215) : bg,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: border.withAlpha(isDark ? 160 : 255), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(color: border.withAlpha(140), thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceVariant : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(primary, 2),
        errorBorder: inputBorder(AppColors.error),
        focusedErrorBorder: inputBorder(AppColors.error, 2),
        hintStyle: TextStyle(color: textSecondary, fontSize: 14),
        labelStyle: TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.1),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: buttonShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: primary.withAlpha(isDark ? 40 : 30),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        labelStyle: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        checkmarkColor: primary,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm))),
          side: WidgetStatePropertyAll(BorderSide(color: border)),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? primary : card,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? onPrimary : textPrimary,
          ),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border.withAlpha(120),
        circularTrackColor: border.withAlpha(120),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: border,
        overlayColor: primary.withAlpha(30),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? onPrimary : textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : surfaceVariant),
        trackOutlineColor: WidgetStatePropertyAll(border),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w800),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? cardHigh : textPrimary,
        contentTextStyle: TextStyle(color: isDark ? textPrimary : Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onPrimary,
        unselectedLabelColor: textSecondary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(radiusSm)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: primary.withAlpha(isDark ? 40 : 30),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontSize: 11.5,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w800 : FontWeight.w600,
              color: states.contains(WidgetState.selected) ? primary : textSecondary,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? primary : textSecondary,
              size: 24,
            )),
      ),
    );
  }
}
