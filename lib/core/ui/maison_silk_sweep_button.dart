import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';

class MaisonSilkSweepButton extends StatefulWidget {
  const MaisonSilkSweepButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
    this.iconOnly = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? icon;
  final bool iconOnly;

  @override
  State<MaisonSilkSweepButton> createState() => _MaisonSilkSweepButtonState();
}

class _MaisonSilkSweepButtonState extends State<MaisonSilkSweepButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                AnimatedContainer(
                  duration: MaisonMotion.silkSweep,
                  curve: Curves.easeOutCubic,
                  height: 30,
                  width: _hovered ? 220 : 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        AppTheme.richBurgundy.withValues(alpha: 0.12),
                        AppTheme.primaryBurgundy.withValues(alpha: 0.26),
                        AppTheme.richBurgundy.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.24, 0.5, 0.76, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    textDirection: TextDirection.rtl,
                    children: [
                      if (widget.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: AppTheme.warmIvory.withValues(
                              alpha: _hovered ? 1.0 : 0.88,
                            ),
                            size: 20,
                          ),
                          child: widget.icon!,
                        ),
                        if (!widget.iconOnly) const SizedBox(width: 8),
                      ],
                      if (!widget.iconOnly)
                        Flexible(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            style: TextStyle(
                              fontFamily: AppTheme.fontArabic,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: AppTheme.warmIvory.withValues(
                                alpha: _hovered ? 1.0 : 0.88,
                              ),
                            ),
                            child: widget.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    widget.label,
                                    textDirection: TextDirection.rtl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
