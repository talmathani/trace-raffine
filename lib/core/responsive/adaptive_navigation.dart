import 'package:flutter/material.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'app_breakpoints.dart';

class AdaptiveNavigationItem {
  const AdaptiveNavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
}

class AdaptiveNavigationScaffold extends StatelessWidget {
  const AdaptiveNavigationScaffold({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<AdaptiveNavigationItem> destinations;

  @override
  Widget build(BuildContext context) {
    final screenClass = context.screenClass;

    if (screenClass == AppScreenClass.compact) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
          backgroundColor: AppTheme.obsidian,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppTheme.deepBurgundy,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.editorialControlRadius,
            ),
            side: const BorderSide(color: AppTheme.divider),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontFamily: AppTheme.fontArabic,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.warmIvory : AppTheme.mutedIvory,
            );
          }),
          destinations: destinations
              .map(
                (item) => NavigationDestination(
                  icon: item.icon,
                  selectedIcon: item.selectedIcon,
                  label: item.label,
                ),
              )
              .toList(growable: false),
        ),
      );
    }

    final extended = screenClass == AppScreenClass.large;

    return Scaffold(
      body: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              right: MediaQuery.paddingOf(context).right,
              bottom: MediaQuery.paddingOf(context).bottom,
              left: MediaQuery.paddingOf(context).left,
            ),
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: extended,
              backgroundColor: AppTheme.obsidian,
              indicatorColor: AppTheme.deepBurgundy,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.editorialControlRadius,
                ),
                side: const BorderSide(color: AppTheme.divider),
              ),
              selectedIconTheme: const IconThemeData(
                color: AppTheme.softRose,
                size: 23,
              ),
              unselectedIconTheme: const IconThemeData(
                color: AppTheme.mutedIvory,
                size: 21,
              ),
              selectedLabelTextStyle: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
              unselectedLabelTextStyle: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.mutedIvory,
              ),
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.selected,
              destinations: destinations
                  .map(
                    (item) => NavigationRailDestination(
                      icon: item.icon,
                      selectedIcon: item.selectedIcon,
                      label: Text(item.label),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
