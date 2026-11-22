import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_palettes.dart';
import '../../core/widgets/animated_background.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/ui_kit.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/settings_provider.dart';

String effectName(AppLocalizations l10n, BackgroundEffect e) => switch (e) {
      BackgroundEffect.none => l10n.fxNone,
      BackgroundEffect.orbs => l10n.fxOrbs,
      BackgroundEffect.particles => l10n.fxParticles,
      BackgroundEffect.waves => l10n.fxWaves,
      BackgroundEffect.grid => l10n.fxGrid,
      BackgroundEffect.aurora => l10n.fxAurora,
      BackgroundEffect.bokeh => l10n.fxBokeh,
      BackgroundEffect.stars => l10n.fxStars,
    };

IconData effectIcon(BackgroundEffect e) => switch (e) {
      BackgroundEffect.none => Icons.block_rounded,
      BackgroundEffect.orbs => Icons.bubble_chart_rounded,
      BackgroundEffect.particles => Icons.hub_rounded,
      BackgroundEffect.waves => Icons.waves_rounded,
      BackgroundEffect.grid => Icons.grid_4x4_rounded,
      BackgroundEffect.aurora => Icons.gradient_rounded,
      BackgroundEffect.bokeh => Icons.blur_on_rounded,
      BackgroundEffect.stars => Icons.auto_awesome_rounded,
    };

/// Appearance: light/dark, 20 colour themes with different shapes, and the
/// animated / touch-reactive background.
class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final look = ref.watch(appearanceProvider);
    final mode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider).languageCode;
    final notifier = ref.read(appearanceProvider.notifier);
    final current = AppPalettes.byId(look.paletteId);
    final brightness = theme.brightness;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.themesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          // ---------------- Light / dark ----------------
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto_rounded), label: Text(l10n.profileThemeSystem)),
              ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_rounded), label: Text(l10n.profileThemeLight)),
              ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_rounded), label: Text(l10n.profileThemeDark)),
            ],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).setThemeMode(s.first),
          ),

          // ---------------- Palettes ----------------
          SectionHeader(title: '${l10n.themesColors} • ${AppPalettes.all.length}'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
            children: [
              for (final p in AppPalettes.all)
                _PaletteTile(
                  palette: p,
                  brightness: brightness,
                  selected: p.id == current.id,
                  name: p.name(locale),
                  shapeLabel: _shapeName(l10n, p.shape),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    notifier.update(look.copyWith(paletteId: p.id));
                  },
                ),
            ],
          ),

          // ---------------- Animated background ----------------
          SectionHeader(title: l10n.themesBackground),
          AppCard(
            padding: const EdgeInsets.fromLTRB(14, 4, 8, 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(Icons.animation_rounded, color: theme.colorScheme.primary),
                  title: Text(l10n.themesAnimated, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(l10n.themesAnimatedDesc, style: theme.textTheme.bodySmall),
                  value: look.animated,
                  onChanged: (v) => notifier.update(look.copyWith(animated: v)),
                ),
                if (look.animated) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(Icons.touch_app_rounded, color: theme.colorScheme.primary),
                    title: Text(l10n.themesInteractive, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(l10n.themesInteractiveDesc, style: theme.textTheme.bodySmall),
                    value: look.interactive,
                    onChanged: (v) => notifier.update(look.copyWith(interactive: v)),
                  ),
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Text(l10n.themesIntensity, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Expanded(
                        child: Slider(
                          value: look.intensity,
                          min: 0.3,
                          max: 1.0,
                          divisions: 7,
                          onChanged: (v) => notifier.update(look.copyWith(intensity: v)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (look.animated) ...[
            SectionHeader(title: l10n.themesEffect),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
              children: [
                _EffectTile(
                  label: '${l10n.fxAuto} (${effectName(l10n, current.effect)})',
                  icon: Icons.auto_fix_high_rounded,
                  palette: current,
                  brightness: brightness,
                  effect: current.effect,
                  selected: look.effect == 'auto',
                  onTap: () => notifier.update(look.copyWith(effect: 'auto')),
                ),
                for (final e in BackgroundEffect.values.where((e) => e != BackgroundEffect.none))
                  _EffectTile(
                    label: effectName(l10n, e),
                    icon: effectIcon(e),
                    palette: current,
                    brightness: brightness,
                    effect: e,
                    selected: look.effect == e.name,
                    onTap: () => notifier.update(look.copyWith(effect: e.name)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text(l10n.themesBatteryNote, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  static String _shapeName(AppLocalizations l10n, ShapeStyle s) => switch (s) {
        ShapeStyle.sharp => l10n.shapeSharp,
        ShapeStyle.soft => l10n.shapeSoft,
        ShapeStyle.rounded => l10n.shapeRounded,
        ShapeStyle.pill => l10n.shapePill,
      };
}

/// Mini mock-up of a theme: its background effect, a card with its corner
/// shape, accent button and colour dots.
class _PaletteTile extends StatelessWidget {
  final AppPalette palette;
  final Brightness brightness;
  final bool selected;
  final String name;
  final String shapeLabel;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.brightness,
    required this.selected,
    required this.name,
    required this.shapeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = brightness == Brightness.dark;
    final primary = palette.primary(brightness);
    final card = dark ? palette.cardDark : palette.cardLight;
    final text = dark ? palette.textDark : palette.textLight;
    final sub = dark ? palette.textSecondaryDark : palette.textSecondaryLight;
    final r = palette.radiusLg;

    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r * 0.7 + 4),
            border: Border.all(color: selected ? primary : context.borderColor, width: selected ? 2.5 : 1),
            boxShadow: selected ? [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 14)] : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r * 0.7 + 2),
            child: Stack(
              fit: StackFit.expand,
              children: [
                BackgroundPreview(palette: palette, brightness: brightness, effect: palette.effect),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mini card
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: card.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(r * 0.55),
                          border: Border.all(color: dark ? palette.borderDark : palette.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(gradient: palette.accentGradient, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(height: 5, width: 46, decoration: BoxDecoration(color: text, borderRadius: BorderRadius.circular(3))),
                                  const SizedBox(height: 4),
                                  Container(height: 4, width: 30, decoration: BoxDecoration(color: sub, borderRadius: BorderRadius.circular(3))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Mini button
                      Container(
                        height: 18,
                        decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(r * 0.45)),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          for (final c in [palette.accent, palette.secondary, palette.tertiary])
                            Container(
                              margin: const EdgeInsetsDirectional.only(end: 4),
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: card, width: 1.5)),
                            ),
                          const Spacer(),
                          if (selected)
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                              child: Icon(Icons.check_rounded, size: 14, color: palette.onPrimary(brightness)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(shapeLabel, maxLines: 1, style: TextStyle(color: sub, fontSize: 10.5, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EffectTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final AppPalette palette;
  final Brightness brightness;
  final BackgroundEffect effect;
  final bool selected;
  final VoidCallback onTap;

  const _EffectTile({
    required this.label,
    required this.icon,
    required this.palette,
    required this.brightness,
    required this.effect,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.radiusMd),
                border: Border.all(color: selected ? primary : context.borderColor, width: selected ? 2.5 : 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.radiusMd - 1),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BackgroundPreview(palette: palette, brightness: brightness, effect: effect),
                    Center(child: Icon(icon, color: primary.withValues(alpha: 0.9))),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                color: selected ? theme.colorScheme.onSurface : null,
              )),
        ],
      ),
    );
  }
}
