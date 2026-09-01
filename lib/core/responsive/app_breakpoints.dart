import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  static const double large = 1440;

  static bool isCompact(double width) => width < compact;

  static bool isMedium(double width) =>
      width >= compact && width < medium;

  static bool isExpanded(double width) =>
      width >= medium && width < expanded;

  static bool isLarge(double width) => width >= expanded;

  static bool isTablet(double width) => width >= compact;

  static bool isDesktop(double width) => width >= expanded;
}

enum AppScreenClass {
  compact,
  medium,
  expanded,
  large,
}

extension AppScreenClassX on BuildContext {
  AppScreenClass get screenClass {
    final width = MediaQuery.sizeOf(this).width;

    if (width < AppBreakpoints.compact) {
      return AppScreenClass.compact;
    }

    if (width < AppBreakpoints.medium) {
      return AppScreenClass.medium;
    }

    if (width < AppBreakpoints.expanded) {
      return AppScreenClass.expanded;
    }

    return AppScreenClass.large;
  }

  bool get isCompact =>
      screenClass == AppScreenClass.compact;

  bool get isTablet =>
      screenClass == AppScreenClass.medium ||
      screenClass == AppScreenClass.expanded;

  bool get isDesktop =>
      screenClass == AppScreenClass.large;
}
