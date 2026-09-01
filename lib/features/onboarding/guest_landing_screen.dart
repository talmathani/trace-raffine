import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../auth/presentation/pages/register_screen.dart';
import '../../domain/entities/user_role.dart';

class GuestLandingScreen extends StatelessWidget {
  const GuestLandingScreen({super.key});

  void _openLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RegisterScreen(role: UserRole.customer),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -180,
              right: -160,
              child: _glow(
                size: 420,
                color: AppTheme.richBurgundy.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -220,
              left: -180,
              child: _glow(
                size: 460,
                color: AppTheme.softRose.withValues(alpha: 0.07),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 70 : 24,
                  vertical: 30,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(flex: 6, child: _buildBrandSection()),
                            const SizedBox(width: 80),
                            Expanded(flex: 4, child: _buildActionCard(context)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildBrandSection(compact: true),
                            const SizedBox(height: 42),
                            _buildActionCard(context),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandSection({bool compact = false}) {
    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 150 : 190,
          height: compact ? 150 : 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.softRose.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.richBurgundy.withValues(alpha: 0.18),
                blurRadius: 55,
                spreadRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Image.asset(
            'assets/images/logo_burgundy.PNG',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) {
              return const Icon(
                Icons.auto_awesome,
                size: 70,
                color: AppTheme.softRose,
              );
            },
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'TRACÉ RAFFINÉ',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 76, height: 1, color: AppTheme.softRose),
        const SizedBox(height: 28),
        Text(
          'عالم التطريز الرقمي\nبصياغة راقية.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'اكتشف تصاميم التطريز والخرز والملفات الرقمية '
            'المهيأة للإبداع والإنتاج، في منصة تجمع الدقة '
            'والحِرفة والابتكار الرقمي.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppTheme.mutedIvory,
              height: 1.95,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'DIGITAL EMBROIDERY · DESIGN · CRAFT',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.softRose,
            letterSpacing: 2.6,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppTheme.burgundyBlack.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.softRose.withValues(alpha: 0.24)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 45,
            offset: Offset(0, 20),
            color: Colors.black45,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'مرحباً بك',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ رحلتك داخل TRACÉ RAFFINÉ',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 28),
          _buildFeature(
            icon: Icons.auto_awesome_outlined,
            title: 'اكتشف',
            subtitle: 'تصفح عالم التصاميم الرقمية.',
          ),
          const SizedBox(height: 14),
          _buildFeature(
            icon: Icons.design_services_outlined,
            title: 'صمّم',
            subtitle: 'حوّل إبداعك إلى منتجات رقمية.',
          ),
          const SizedBox(height: 14),
          _buildFeature(
            icon: Icons.workspace_premium_outlined,
            title: 'اقتَنِ',
            subtitle: 'اختر ملفات صُممت بدقة واحتراف.',
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () => _openLogin(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => _openRegister(context),
              child: const Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'يمكنك استكشاف المنصة كزائر قبل إنشاء حساب.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: AppTheme.mutedText,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.softRose.withValues(alpha: 0.30),
            ),
          ),
          child: Icon(icon, size: 19, color: AppTheme.softRose),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.warmIvory,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  color: AppTheme.mutedText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glow({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
