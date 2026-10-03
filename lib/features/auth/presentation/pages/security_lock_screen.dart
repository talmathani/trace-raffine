import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SecurityLockScreen extends StatefulWidget {
  const SecurityLockScreen({super.key});

  @override
  State<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends State<SecurityLockScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _logout() {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = context.isCompact;
    final expandedScene = context.isExpanded || context.isLarge;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (expandedScene)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: size.width * 0.56,
              child: ClipRect(
                child: Image.asset(
                  'assets/images/LOG IN.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.08, 0.0),
                  filterQuality: FilterQuality.high,
                ),
              ),
            )
          else
            Positioned.fill(
              child: Image.asset(
                'assets/images/LOG IN.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, 0.0),
                filterQuality: FilterQuality.high,
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: expandedScene
                        ? [
                            AppTheme.obsidian.withValues(alpha: 0.78),
                            AppTheme.burgundyBlack.withValues(alpha: 0.52),
                            AppTheme.deepBurgundy.withValues(alpha: 0.18),
                            Colors.transparent,
                          ]
                        : [
                            AppTheme.obsidian.withValues(alpha: 0.30),
                            AppTheme.deepBurgundy.withValues(alpha: 0.22),
                            AppTheme.obsidian.withValues(alpha: 0.40),
                          ],
                    stops: expandedScene
                        ? const [0.0, 0.36, 0.62, 1.0]
                        : const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
          ),

          if (!expandedScene)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.obsidian.withValues(alpha: 0.05),
                        AppTheme.deepBurgundy.withValues(alpha: 0.30),
                      ],
                      stops: const [0.0, 0.58, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: expandedScene
                        ? const Alignment(0.58, -0.16)
                        : const Alignment(0.0, -0.28),
                    radius: expandedScene ? 0.92 : 0.88,
                    colors: expandedScene
                        ? [
                            AppTheme.roseBurgundy.withValues(alpha: 0.075),
                            AppTheme.primaryBurgundy.withValues(alpha: 0.025),
                            Colors.transparent,
                          ]
                        : [
                            AppTheme.roseBurgundy.withValues(alpha: 0.06),
                            AppTheme.primaryBurgundy.withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                    stops: const [0.0, 0.44, 1.0],
                  ),
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CoutureBeadsPainter(
                  denseSide: expandedScene ? 1.0 : 0.68,
                ),
              ),
            ),
          ),

          Align(
            alignment: expandedScene
                ? Alignment.centerLeft
                : Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 20 : 48,
                compact ? 22 : 48,
                compact ? 20 : 48,
                compact ? 34 : 64,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: expandedScene ? 500 : 560,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: compact ? 6 : 18),

                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(
                          0.18,
                          0.58,
                          curve: MaisonMotion.easeOut,
                        ),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.08, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _entranceController,
                                curve: const Interval(
                                  0.18,
                                  0.58,
                                  curve: MaisonMotion.easeOut,
                                ),
                              ),
                            ),
                        child: Text(
                          'تنبيه أمني',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            fontSize: compact ? 42 : 58,
                            fontWeight: FontWeight.w700,
                            height: 0.98,
                            letterSpacing: -1.2,
                            color: AppTheme.warmIvory,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: compact ? 30 : 42),
                    SizedBox(height: compact ? 26 : 34),

                    _buildSecurityContent(context),

                    SizedBox(height: compact ? 20 : 24),

                    _buildPrimarySecurityButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityContent(BuildContext context) {
    final compact = context.isCompact;

    final contentCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.42, 0.78, curve: MaisonMotion.easeOut),
    );

    return FadeTransition(
      opacity: contentCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.035, 0.0),
          end: Offset.zero,
        ).animate(contentCurve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 54 : 62,
                  height: compact ? 54 : 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.softRose.withValues(alpha: 0.68),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: compact ? 25 : 28,
                    color: AppTheme.softRose.withValues(alpha: 0.88),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'تم تعليق جلستك مؤقتًا',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            fontSize: compact ? 19 : 21,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warmIvory,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'كإجراء احترازي لحماية محتوى TRACÉ RAFFINÉ الرقمي وحقوق التصميم.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            fontSize: compact ? 12 : 13,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.mutedIvory.withValues(alpha: 0.76),
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Align(
              alignment: Alignment.centerRight,
              child: Container(width: 54, height: 1, color: AppTheme.softRose),
            ),

            const SizedBox(height: 18),

            Text(
              'نقدّر تفهّمك والتزامك بسياسات حماية المحتوى وحقوق الملكية الفكرية.',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: compact ? 13 : 14,
                color: AppTheme.mutedIvory.withValues(alpha: 0.68),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimarySecurityButton(BuildContext context) {
    final buttonCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.78, 1.0, curve: MaisonMotion.easeOut),
    );

    return FadeTransition(
      opacity: buttonCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.015, 0.0),
          end: Offset.zero,
        ).animate(buttonCurve),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: _SilkSweepButton(
            label: 'العودة إلى تسجيل الدخول',
            isLoading: _isLoggingOut,
            onTap: _isLoggingOut ? null : _logout,
          ),
        ),
      ),
    );
  }
}

class _SilkSweepButton extends StatefulWidget {
  const _SilkSweepButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<_SilkSweepButton> createState() => _SilkSweepButtonState();
}

class _SilkSweepButtonState extends State<_SilkSweepButton> {
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
            duration: AppTheme.editorialFluid,
            curve: MaisonMotion.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppTheme.editorialControlRadius,
              ),
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.14),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: Offset(0, 10),
                  color: Colors.black38,
                ),
              ],
            ),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                AnimatedContainer(
                  duration: MaisonMotion.silkSweep,
                  curve: MaisonMotion.easeOut,
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
                  child: AnimatedDefaultTextStyle(
                    duration: AppTheme.editorialReveal,
                    curve: MaisonMotion.easeOut,
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
                            child: CircularProgressIndicator(strokeWidth: 2),
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
        ),
      ),
    );
  }
}

class _CoutureBeadsPainter extends CustomPainter {
  const _CoutureBeadsPainter({required this.denseSide});

  final double denseSide;

  @override
  void paint(Canvas canvas, Size size) {
    final beads = <({double x, double y, double r, double a})>[
      (x: 0.80, y: 0.16, r: 2.0, a: 0.22),
      (x: 0.88, y: 0.23, r: 3.0, a: 0.30),
      (x: 0.73, y: 0.31, r: 1.6, a: 0.18),
      (x: 0.92, y: 0.38, r: 2.4, a: 0.26),
      (x: 0.81, y: 0.47, r: 3.6, a: 0.34),
      (x: 0.69, y: 0.55, r: 1.8, a: 0.18),
      (x: 0.87, y: 0.62, r: 2.6, a: 0.28),
      (x: 0.76, y: 0.70, r: 1.5, a: 0.16),
      (x: 0.94, y: 0.77, r: 2.8, a: 0.24),
      (x: 0.65, y: 0.84, r: 1.8, a: 0.15),
    ];

    final glow = Paint()..style = PaintingStyle.fill;
    final bead = Paint()..style = PaintingStyle.fill;

    for (final item in beads) {
      final center = Offset(size.width * item.x, size.height * item.y);

      final radius = item.r * (size.shortestSide / 520.0).clamp(0.78, 1.16);

      final alpha = item.a * denseSide;

      glow.color = AppTheme.roseBurgundy.withValues(alpha: alpha * 0.20);

      canvas.drawCircle(center, radius * 2.4, glow);

      bead.shader = RadialGradient(
        colors: [
          AppTheme.warmIvory.withValues(alpha: alpha * 0.78),
          AppTheme.softRose.withValues(alpha: alpha),
          AppTheme.primaryBurgundy.withValues(alpha: alpha * 0.92),
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8));

      canvas.drawCircle(center, radius, bead);

      bead.shader = null;
    }
  }

  @override
  bool shouldRepaint(covariant _CoutureBeadsPainter oldDelegate) {
    return oldDelegate.denseSide != denseSide;
  }
}
