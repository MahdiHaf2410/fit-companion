import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'user_theme_mode';

  ThemeModeNotifier(this._prefs) : super(_loadInitial(_prefs));

  static ThemeMode _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    switch (saved) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs.setString(_key, val);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences _prefs;
  static const _key = 'user_locale';

  LocaleNotifier(this._prefs) : super(_loadInitial(_prefs));

  static Locale _loadInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_key);
    if (saved == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _prefs.setString(_key, locale.languageCode);
  }

  Future<void> toggleLanguage() async {
    if (state.languageCode == 'ar') {
      await setLocale(const Locale('en'));
    } else {
      await setLocale(const Locale('ar'));
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocaleNotifier(prefs);
});

// ---------------------------------------------------------------------------
// Visual themes (v1.4)
// ---------------------------------------------------------------------------

/// Appearance options beyond light/dark: palette, animated background, effect.
class AppearanceSettings {
  final String paletteId;
  final bool animated; // animated background on/off
  final String effect; // 'auto' (palette default) or a BackgroundEffect name
  final bool interactive; // background reacts to touches
  final double intensity; // 0.3 .. 1.0

  const AppearanceSettings({
    this.paletteId = 'neon',
    this.animated = true,
    this.effect = 'auto',
    this.interactive = true,
    this.intensity = 0.7,
  });

  AppearanceSettings copyWith({String? paletteId, bool? animated, String? effect, bool? interactive, double? intensity}) =>
      AppearanceSettings(
        paletteId: paletteId ?? this.paletteId,
        animated: animated ?? this.animated,
        effect: effect ?? this.effect,
        interactive: interactive ?? this.interactive,
        intensity: intensity ?? this.intensity,
      );
}

class AppearanceNotifier extends StateNotifier<AppearanceSettings> {
  final SharedPreferences _prefs;

  AppearanceNotifier(this._prefs)
      : super(AppearanceSettings(
          paletteId: _prefs.getString('ui_palette') ?? 'neon',
          animated: _prefs.getBool('ui_animated') ?? true,
          effect: _prefs.getString('ui_effect') ?? 'auto',
          interactive: _prefs.getBool('ui_interactive') ?? true,
          intensity: _prefs.getDouble('ui_intensity') ?? 0.7,
        ));

  Future<void> update(AppearanceSettings s) async {
    state = s;
    await _prefs.setString('ui_palette', s.paletteId);
    await _prefs.setBool('ui_animated', s.animated);
    await _prefs.setString('ui_effect', s.effect);
    await _prefs.setBool('ui_interactive', s.interactive);
    await _prefs.setDouble('ui_intensity', s.intensity);
  }
}

final appearanceProvider = StateNotifierProvider<AppearanceNotifier, AppearanceSettings>((ref) {
  return AppearanceNotifier(ref.watch(sharedPreferencesProvider));
});
