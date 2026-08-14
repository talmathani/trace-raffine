import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LuxuryCard extends StatefulWidget {
  const LuxuryCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 20,
    this.onTap,
    this.hoverLift = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hoverLift;

  @override
  State<LuxuryCard> createState() => _LuxuryCardState();
}

class _LuxuryCardState extends State<LuxuryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: widget.margin,
      transform: widget.hoverLift && _hovered
          ? (Matrix4.identity()..translateByDouble(0.0, -2.0, 0.0, 1.0))
          : Matrix4.identity(),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: AppTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: _hovered
              ? AppTheme.softRose.withValues(alpha: 0.30)
              : AppTheme.divider,
        ),
        boxShadow: _hovered
            ? [
                BoxShadow(
                  color: AppTheme.obsidian.withValues(alpha: 0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: widget.child,
    );

    final interactive = MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
    );

    if (widget.onTap == null) {
      return interactive;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: interactive,
    );
  }
}
