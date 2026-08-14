import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LuxuryIcon extends StatelessWidget {
  const LuxuryIcon({
    super.key,
    required this.icon,
    this.size = 22,
    this.color,
    this.background,
    this.borderRadius = 12,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final Color? background;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background ?? AppTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Icon(icon, size: size, color: color ?? AppTheme.softRose),
    );
  }
}
