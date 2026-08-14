import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LuxuryButton extends StatefulWidget {
  const LuxuryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 50,
    this.padding = const EdgeInsets.symmetric(horizontal: 22),
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool expanded;

  @override
  State<LuxuryButton> createState() => _LuxuryButtonState();
}

class _LuxuryButtonState extends State<LuxuryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: widget.height,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: enabled
            ? (_hovered
                  ? AppTheme.softRose.withValues(alpha: 0.14)
                  : AppTheme.deepBurgundy)
            : AppTheme.deepBurgundy.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? (_hovered
                    ? AppTheme.softRose.withValues(alpha: 0.65)
                    : AppTheme.divider)
              : AppTheme.divider.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 19,
              color: enabled ? AppTheme.softRose : AppTheme.mutedText,
            ),
            const SizedBox(width: 9),
          ],
          Text(
            widget.label,
            style: TextStyle(
              color: enabled ? AppTheme.warmIvory : AppTheme.mutedText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    final button = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: content,
      ),
    );

    return widget.expanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
