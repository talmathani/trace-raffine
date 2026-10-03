import 'package:flutter/material.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';

class MaisonSurface extends StatelessWidget {
  const MaisonSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = AppTheme.editorialListRadius,
    this.color = AppTheme.burgundyBlack,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: child,
    );
  }
}
