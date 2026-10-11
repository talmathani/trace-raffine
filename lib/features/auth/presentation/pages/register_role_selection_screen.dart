import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_back_button.dart';
import '../../../../domain/entities/user_role.dart';
import 'register_screen.dart';

class RegisterRoleSelectionScreen extends StatefulWidget {
  const RegisterRoleSelectionScreen({super.key});

  @override
  State<RegisterRoleSelectionScreen> createState() =>
      _RegisterRoleSelectionScreenState();
}

class _RegisterRoleSelectionScreenState
    extends State<RegisterRoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

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

  void _openRegister(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MaisonMotion.pageTransition,
        reverseTransitionDuration: MaisonMotion.pageReverseTransition,
        pageBuilder: (_, animation, secondaryAnimation) =>
            RegisterScreen(role: role),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: MaisonMotion.easeOut,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.025, 0.0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 560;
    final expandedScene = size.width >= 900;

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
              child: CustomPaint(
                painter: const _CoutureBeadsPainter(denseSide: 0.88),
              ),
            ),
          ),

          PositionedDirectional(
            top: AppTheme.spaceLoginLg,
            start: AppTheme.pageHorizontal,
            child: MaisonBackButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          Align(
            alignment: expandedScene
                ? Alignment.centerLeft
                : Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? AppTheme.pageHorizontal : AppTheme.space3Xl,
                compact ? 78 : AppTheme.space3Xl,
                compact ? AppTheme.pageHorizontal : AppTheme.space3Xl,
                compact ? AppTheme.spaceLogin3Xl : AppTheme.space4Xl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: expandedScene ? 500 : 560,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: compact
                          ? AppTheme.spaceSm
                          : AppTheme.spaceLoginLg,
                    ),

                    _entrance(
                      interval: const Interval(
                        0.18,
                        0.58,
                        curve: MaisonMotion.easeOut,
                      ),
                      begin: const Offset(0.08, 0.0),
                      child: Text(
                        'إنشاء حساب',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: AppTheme.fontArabic,
                          fontSize: compact
                              ? AppTheme.editorialHeroCompactSize
                              : AppTheme.editorialHeroSize,
                          fontWeight: FontWeight.w700,
                          height: 0.98,
                          letterSpacing: -1.2,
                          color: AppTheme.warmIvory,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: compact
                          ? AppTheme.spaceLoginXl
                          : AppTheme.spaceLogin2Xl,
                    ),

                    _entrance(
                      interval: const Interval(
                        0.42,
                        0.72,
                        curve: MaisonMotion.easeOut,
                      ),
                      begin: const Offset(0.035, 0.0),
                      child: _buildRoleHeading(compact),
                    ),

                    SizedBox(
                      height: compact
                          ? AppTheme.spaceLoginXl
                          : AppTheme.spaceLogin2Xl,
                    ),

                    _entrance(
                      interval: const Interval(
                        0.56,
                        0.96,
                        curve: MaisonMotion.easeOut,
                      ),
                      begin: const Offset(0.025, 0.0),
                      child: _buildRoleActions(compact),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleHeading(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختيار نوع الحساب',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: compact
                ? AppTheme.arabicLargeSize
                : AppTheme.arabicLargeSize + 2,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm - 2),
        Text(
          'اختر نوع الحساب للمتابعة',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: AppTheme.arabicMediumSize,
            fontWeight: FontWeight.w400,
            color: AppTheme.mutedIvory.withValues(alpha: 0.72),
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm + 2),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 54,
            height: 1,
            color: AppTheme.softRose.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleActions(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorialButton(
          onPressed: () {
            _openRegister(context, UserRole.customer);
          },
          variant: EditorialButtonVariant.secondary,
          icon: const Icon(Icons.people_outline_rounded),
          label: 'عميل',
          compact: compact,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'تصفح وشراء التصاميم',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: AppTheme.arabicSmallSize,
            color: AppTheme.mutedIvory.withValues(alpha: 0.66),
            height: 1.45,
          ),
        ),
        SizedBox(
          height: compact
              ? AppTheme.spaceLoginLg + 4
              : AppTheme.spaceLoginXl + 2,
        ),
        EditorialButton(
          onPressed: () {
            _openRegister(context, UserRole.designer);
          },
          variant: EditorialButtonVariant.secondary,
          icon: const Icon(Icons.draw_outlined),
          label: 'مصمم',
          compact: compact,
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          'عرض وبيع التصاميم',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: AppTheme.arabicSmallSize,
            color: AppTheme.mutedIvory.withValues(alpha: 0.66),
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _entrance({
    required Interval interval,
    required Offset begin,
    required Widget child,
  }) {
    final curve = CurvedAnimation(parent: _entranceController, curve: interval);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curve),
        child: child,
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
