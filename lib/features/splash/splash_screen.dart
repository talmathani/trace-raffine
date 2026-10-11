import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_silk_sweep_button.dart';

import '../auth/presentation/pages/register_role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onLogin, required this.onGuest});

  final VoidCallback onLogin;
  final VoidCallback onGuest;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _openRegister() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MaisonMotion.pageTransition,
        reverseTransitionDuration: MaisonMotion.pageReverseTransition,
        pageBuilder: (_, animation, secondaryAnimation) {
          return const RegisterRoleSelectionScreen();
        },
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: MaisonMotion.easeOut,
            reverseCurve: MaisonMotion.easeIn,
          );

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.035, 0.0),
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
          _buildScene(expandedScene: expandedScene),
          _buildContent(compact: compact, expandedScene: expandedScene),
        ],
      ),
    );
  }

  Widget _buildScene({required bool expandedScene}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (expandedScene)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            width: MediaQuery.sizeOf(context).width * 0.56,
            child: ClipRect(
              child: Image.asset(
                'assets/images/1111.PNG',
                fit: BoxFit.cover,
                alignment: const Alignment(0.08, 0.0),
                filterQuality: FilterQuality.high,
              ),
            ),
          )
        else
          Positioned.fill(
            child: Image.asset(
              'assets/images/1111.PNG',
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
              painter: _CoutureBeadsPainter(
                denseSide: expandedScene ? 1.0 : 0.68,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent({required bool compact, required bool expandedScene}) {
    return Align(
      alignment: expandedScene ? Alignment.centerLeft : Alignment.bottomCenter,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          compact ? 20 : 48,
          compact ? 22 : 48,
          compact ? 20 : 48,
          compact ? 34 : 64,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: expandedScene ? 500 : 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: compact ? 6 : 18),
              _entrance(
                interval: const Interval(
                  0.18,
                  0.58,
                  curve: Curves.easeOutCubic,
                ),
                begin: const Offset(0.08, 0.0),
                child: Text(
                  'مرحبًا بك',
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
              SizedBox(height: compact ? 30 : 42),
              _entrance(
                interval: const Interval(
                  0.40,
                  0.72,
                  curve: Curves.easeOutCubic,
                ),
                begin: const Offset(0.035, 0.0),
                child: _buildIntroduction(compact),
              ),
              SizedBox(height: compact ? 26 : 34),
              _entrance(
                interval: const Interval(0.58, 1.0, curve: Curves.easeOutCubic),
                begin: const Offset(0.025, 0.0),
                child: _buildActions(compact),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أول منصة عالمية لبيع ملفات التطريز وشغل الخرز الرقمية',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: compact ? 15 : 17,
            fontWeight: FontWeight.w400,
            color: AppTheme.mutedIvory.withValues(alpha: 0.84),
            height: 1.7,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'اكتشف عالمًا يجمع بين الحرفة، الدقة، والفخامة الرقمية.',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: AppTheme.fontArabic,
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w400,
            color: AppTheme.mutedIvory.withValues(alpha: 0.66),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Container(width: 54, height: 1, color: AppTheme.softRose),
        ),
      ],
    );
  }

  Widget _buildActions(bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: MaisonSilkSweepButton(
            label: 'تسجيل الدخول',
            onTap: widget.onLogin,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 56,
          child: MaisonSilkSweepButton(
            label: 'إنشاء حساب',
            onTap: _openRegister,
          ),
        ),
        SizedBox(height: compact ? 20 : 24),
        SizedBox(
          height: 56,
          child: MaisonSilkSweepButton(
            label: 'استكشاف المنصة',
            onTap: widget.onGuest,
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
