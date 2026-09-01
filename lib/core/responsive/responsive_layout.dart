import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;
  final Widget? large;

  @override
  Widget build(BuildContext context) {
    final screenClass = context.screenClass;

    switch (screenClass) {
      case AppScreenClass.compact:
        return compact;

      case AppScreenClass.medium:
        return medium ?? compact;

      case AppScreenClass.expanded:
        return expanded ?? medium ?? compact;

      case AppScreenClass.large:
        return large ?? expanded ?? medium ?? compact;
    }
  }
}
