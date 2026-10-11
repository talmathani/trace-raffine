import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class MaisonBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  const MaisonBackButton({
    super.key,
    required this.onPressed,
    this.padding = EdgeInsets.zero,
    this.iconSize = 19,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'رجوع',
      onPressed: onPressed,
      padding: padding,
      constraints: const BoxConstraints(
        minWidth: AppTheme.touchTargetMin,
        minHeight: AppTheme.touchTargetMin,
      ),
      splashRadius: 24,
      icon: Icon(
        Icons.arrow_back_ios_rounded,
        size: iconSize,
        color: AppTheme.warmIvory,
      ),
    );
  }
}
