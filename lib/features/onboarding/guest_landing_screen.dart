import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_silk_sweep_button.dart';
import '../auth/login_screen.dart';
import '../auth/presentation/pages/register_screen.dart';
import '../../domain/entities/user_role.dart';

class GuestLandingScreen extends StatefulWidget {
  const GuestLandingScreen({super.key});

  @override
  State<GuestLandingScreen> createState() => _GuestLandingScreenState();
}

class _GuestLandingScreenState extends State<GuestLandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _imageReveal;
  late final Animation<double> _contentReveal;
  late final Animation<double> _titleReveal;
  late final Animation<double> _actionsReveal;
  late final Animation<double> _footerReveal;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    );

    _imageReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.58, curve: MaisonMotion.easeOut),
    );

    _contentReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.58, curve: MaisonMotion.easeOut),
    );

    _titleReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.18, 0.58, curve: MaisonMotion.easeOut),
    );

    _actionsReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: MaisonMotion.easeOut),
    );

    _footerReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1.0, curve: MaisonMotion.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MaisonMotion.pageTransition,
        reverseTransitionDuration: MaisonMotion.pageReverseTransition,
        pageBuilder: (_, animation, secondaryAnimation) {
          return const LoginScreen();
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
                begin: const Offset(0.035, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: MaisonMotion.pageTransition,
        reverseTransitionDuration: MaisonMotion.pageReverseTransition,
        pageBuilder: (_, animation, secondaryAnimation) {
          return const RegisterScreen(role: UserRole.customer);
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
                begin: const Offset(0.035, 0),
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
    final isWide = context.isExpanded || context.isLarge;

    if (isWide) {
      return _buildDesktop();
    }

    return _buildCompact();
  }

  Widget _buildDesktop() {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildHeroImage(),
          _buildDesktopVeil(),
          Positioned(
            top: 30,
            right: 42,
            child: FadeTransition(
              opacity: _contentReveal,
              child: _buildBrand(),
            ),
          ),
          Positioned(
            left: 54,
            top: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _contentReveal,
              child: Container(
                width: 1,
                height: double.infinity,
                color: AppTheme.softRose.withValues(alpha: 0.24),
              ),
            ),
          ),
          Positioned(
            left: 86,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildDesktopContent(),
            ),
          ),
          Positioned(
            right: 64,
            bottom: 54,
            child: SizedBox(width: 420, child: _buildActions()),
          ),
          Positioned(
            left: 54,
            bottom: 28,
            child: FadeTransition(
              opacity: _footerReveal,
              child: _buildFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildHeroImage(compact: true),
          _buildCompactVeil(),
          Positioned(
            top: 24,
            right: 24,
            child: FadeTransition(
              opacity: _contentReveal,
              child: _buildBrand(),
            ),
          ),
          Positioned(
            left: 26,
            right: 26,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: const Alignment(-1.0, -0.08),
              child: _buildCompactContent(),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 26,
            child: _buildActions(compact: true),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage({bool compact = false}) {
    return AnimatedBuilder(
      animation: _imageReveal,
      builder: (context, child) {
        final value = _imageReveal.value;

        return Opacity(
          opacity: 0.72 + value * 0.28,
          child: Transform.scale(
            scale: compact ? 1.055 - value * 0.055 : 1.045 - value * 0.045,
            child: child,
          ),
        );
      },
      child: Image.asset(
        'assets/images/1111.PNG',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildDesktopVeil() {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.obsidian.withValues(alpha: 0.94),
                AppTheme.burgundyBlack.withValues(alpha: 0.76),
                AppTheme.deepBurgundy.withValues(alpha: 0.28),
                Colors.transparent,
              ],
              stops: const [0.0, 0.34, 0.66, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.obsidian.withValues(alpha: 0.10),
                Colors.transparent,
                AppTheme.obsidian.withValues(alpha: 0.66),
              ],
              stops: const [0.0, 0.50, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.62, -0.18),
              radius: 0.92,
              colors: [
                AppTheme.roseBurgundy.withValues(alpha: 0.10),
                AppTheme.primaryBurgundy.withValues(alpha: 0.035),
                Colors.transparent,
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactVeil() {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.obsidian.withValues(alpha: 0.18),
                AppTheme.deepBurgundy.withValues(alpha: 0.10),
                AppTheme.obsidian.withValues(alpha: 0.80),
              ],
              stops: const [0.0, 0.42, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.obsidian.withValues(alpha: 0.68),
                Colors.transparent,
              ],
              stops: const [0.0, 0.78],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.0, -0.28),
              radius: 0.88,
              colors: [
                AppTheme.roseBurgundy.withValues(alpha: 0.075),
                AppTheme.primaryBurgundy.withValues(alpha: 0.025),
                Colors.transparent,
              ],
              stops: const [0.0, 0.44, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrand() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'TRACÉ RAFFINÉ',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: AppTheme.fontEditorial,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 4.2,
            color: AppTheme.warmIvory,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopContent() {
    return FadeTransition(
      opacity: _titleReveal,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(_titleReveal),
        child: SizedBox(
          width: 560,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TRACÉ RAFFINÉ',
                style: TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 5.0,
                  color: AppTheme.softRose,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'حيث تبدأ\nالحكاية الراقية',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppTheme.fontEditorial,
                  fontSize: 68,
                  height: 0.96,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 24),
              _buildRule(54),
              const SizedBox(height: 20),
              const Text(
                'اكتشف عالمًا من التصميم والأناقة، '
                'حيث تتحول الرؤية إلى قطعة تحمل بصمتك.',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  fontSize: 16,
                  height: 1.9,
                  color: AppTheme.mutedIvory,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactContent() {
    return FadeTransition(
      opacity: _titleReveal,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(_titleReveal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'TRACÉ RAFFINÉ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontEditorial,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 4.4,
                color: AppTheme.softRose,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'حيث تبدأ\nالحكاية الراقية',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontEditorial,
                fontSize: 48,
                height: 0.97,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 18),
            _buildRule(48),
            const SizedBox(height: 16),
            const SizedBox(
              width: 340,
              child: Text(
                'اكتشف عالمًا من التصميم والأناقة، '
                'حيث تتحول الرؤية إلى قطعة تحمل بصمتك.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  fontSize: 14,
                  height: 1.85,
                  color: AppTheme.mutedIvory,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(double width) {
    return FadeTransition(
      opacity: _actionsReveal,
      child: Container(
        width: width,
        height: 1,
        color: AppTheme.softRose.withValues(alpha: 0.60),
      ),
    );
  }

  Widget _buildActions({bool compact = false}) {
    return FadeTransition(
      opacity: _actionsReveal,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(_actionsReveal),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MaisonSilkSweepButton(
              label: 'تسجيل الدخول',
              onTap: () => _openLogin(context),
            ),
            SizedBox(height: compact ? 10 : 12),
            MaisonSilkSweepButton(
              label: 'إنشاء حساب جديد',
              onTap: () => _openRegister(context),
            ),
            SizedBox(height: compact ? 10 : 12),
            MaisonSilkSweepButton(
              label: 'استكشاف المنصة',
              onTap: () {
                Navigator.of(context).pushNamed('/home');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 1,
          color: AppTheme.softRose.withValues(alpha: 0.38),
        ),
        const SizedBox(width: 12),
        const Text(
          'DIGITAL MAISON',
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: AppTheme.fontTechnical,
            fontSize: 8,
            letterSpacing: 3.0,
            fontWeight: FontWeight.w500,
            color: AppTheme.softRose,
          ),
        ),
      ],
    );
  }
}
