import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'maison_silk_sweep_button.dart';

enum EditorialButtonVariant { primary, secondary }

class EditorialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final String? label;
  final EditorialButtonVariant variant;
  final bool compact;
  final bool iconOnly;
  final bool loading;

  const EditorialButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.variant = EditorialButtonVariant.primary,
    this.compact = false,
    this.iconOnly = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return SizedBox(
        width: compact ? AppTheme.touchTargetMin : AppTheme.touchTargetComfort,
        height: compact ? AppTheme.touchTargetMin : AppTheme.touchTargetComfort,
        child: Center(
          child: MaisonSilkSweepButton(
            label: label ?? '',
            onTap: onPressed,
            isLoading: loading,
            icon: icon,
            iconOnly: true,
          ),
        ),
      );
    }

    return SizedBox(
      height: compact ? AppTheme.touchTargetComfort : 56,
      width: double.infinity,
      child: MaisonSilkSweepButton(
        label: label ?? '',
        onTap: onPressed,
        isLoading: loading,
        icon: icon,
      ),
    );
  }
}

class EditorialSilkSweep extends StatefulWidget {
  final Widget child;
  final bool active;
  final double width;
  final double height;
  final Color accent;
  final Duration duration;

  const EditorialSilkSweep({
    super.key,
    required this.child,
    this.active = true,
    this.width = 220,
    this.height = 30,
    this.accent = AppTheme.richBurgundy,
    this.duration = const Duration(milliseconds: 520),
  });

  @override
  State<EditorialSilkSweep> createState() => _EditorialSilkSweepState();
}

class _EditorialSilkSweepState extends State<EditorialSilkSweep> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: widget.active ? 1 : 0),
                duration: widget.duration,
                curve: Curves.easeOutCubic,
                builder: (context, progress, child) {
                  return CustomPaint(
                    painter: _SilkSweepPainter(
                      progress: progress,
                      accent: widget.accent,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(child: Center(child: widget.child)),
        ],
      ),
    );
  }
}

class _SilkSweepPainter extends CustomPainter {
  final double progress;
  final Color accent;

  const _SilkSweepPainter({required this.progress, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) {
      return;
    }

    final width = size.width;
    final height = size.height;
    final travel = width * 0.72;
    final centerX = width / 2;
    final sweepX = centerX + travel * (1 - progress);

    final silk = Path()
      ..moveTo(sweepX - width * 0.62, height * 0.28)
      ..cubicTo(
        sweepX - width * 0.42,
        height * 0.02,
        sweepX - width * 0.12,
        height * 0.12,
        sweepX + width * 0.08,
        height * 0.28,
      )
      ..cubicTo(
        sweepX + width * 0.28,
        height * 0.44,
        sweepX + width * 0.42,
        height * 0.92,
        sweepX + width * 0.62,
        height * 0.70,
      )
      ..cubicTo(
        sweepX + width * 0.42,
        height * 0.98,
        sweepX + width * 0.10,
        height * 0.88,
        sweepX - width * 0.08,
        height * 0.70,
      )
      ..cubicTo(
        sweepX - width * 0.28,
        height * 0.52,
        sweepX - width * 0.42,
        height * 0.08,
        sweepX - width * 0.62,
        height * 0.28,
      )
      ..close();

    final silkPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          accent.withValues(alpha: 0),
          accent.withValues(alpha: 0.48),
          accent.withValues(alpha: 0.72),
          accent.withValues(alpha: 0.42),
          accent.withValues(alpha: 0),
        ],
        stops: const [0, 0.22, 0.50, 0.78, 1],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(silk, silkPaint);

    final light = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.045),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(silk, light);
  }

  @override
  bool shouldRepaint(covariant _SilkSweepPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.accent != accent;
  }
}
