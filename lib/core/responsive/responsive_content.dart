import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.compactPadding = 16,
    this.tabletPadding = 24,
    this.desktopPadding = 32,
    this.maxWidth = 1440,
  });

  final Widget child;
  final double compactPadding;
  final double tabletPadding;
  final double desktopPadding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = width < AppBreakpoints.compact
        ? compactPadding
        : width < AppBreakpoints.expanded
        ? tabletPadding
        : desktopPadding;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
