import 'package:flutter/material.dart';

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

    if (screenClass == AppScreenClass.compact ||
        screenClass == AppScreenClass.medium) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onDestinationSelected,
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
          SafeArea(
            child: NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              extended: extended,
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
