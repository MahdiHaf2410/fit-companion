import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

/// Root shell with a floating, animated bottom navigation bar.
class AppScaffoldShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldShell({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _NavItem(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, l10n.navHome),
      _NavItem(Icons.restaurant_outlined, Icons.restaurant_rounded, l10n.navNutrition),
      _NavItem(Icons.fitness_center_outlined, Icons.fitness_center_rounded, l10n.navWorkouts),
      _NavItem(Icons.insights_outlined, Icons.insights_rounded, l10n.navProgress),
      _NavItem(Icons.person_outline_rounded, Icons.person_rounded, l10n.navProfile),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _FloatingNavBar(
        items: items,
        currentIndex: navigationShell.currentIndex,
        onTap: _onDestinationSelected,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItem(this.icon, this.selectedIcon, this.label);
}

class _FloatingNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.items, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = context.isDark;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkCardHigh : Colors.white).withAlpha(isDark ? 245 : 250),
          borderRadius: BorderRadius.circular(context.radiusLg + 2),
          border: Border.all(color: context.borderColor.withAlpha(isDark ? 200 : 255)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 110 : 22),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final item = items[i];
            return Expanded(
              child: Semantics(
                selected: selected,
                button: true,
                label: item.label,
                child: InkResponse(
                  onTap: () => onTap(i),
                  radius: 36,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(context.radiusMd),
                        ),
                        child: Icon(
                          selected ? item.selectedIcon : item.icon,
                          size: 22,
                          color: selected ? theme.colorScheme.onPrimary : context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                          color: selected ? theme.colorScheme.onSurface : context.textSecondary,
                        ),
                        child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
