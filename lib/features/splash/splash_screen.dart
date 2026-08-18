import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 720;
    final horizontalPadding = size.width < 360 ? 18.0 : 28.0;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/IMG_4123.PNG',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(color: AppTheme.obsidian);
            },
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.obsidian.withValues(alpha: 0.16),
                  AppTheme.obsidian.withValues(alpha: 0.32),
                  AppTheme.obsidian.withValues(alpha: 0.68),
                  AppTheme.obsidian.withValues(alpha: 0.96),
                ],
                stops: const [0.0, 0.34, 0.68, 1.0],
              ),
            ),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.25),
                radius: 1.15,
                colors: [
                  AppTheme.richBurgundy.withValues(alpha: 0.15),
                  AppTheme.obsidian.withValues(alpha: 0.0),
                  AppTheme.obsidian.withValues(alpha: 0.42),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  const Spacer(flex: 5),

                  Image.asset(
                    'assets/images/logo_burgundy.PNG',
                    width: isCompact ? 190 : 230,
                    fit: BoxFit.contain,
                  ),

                  SizedBox(height: isCompact ? 22 : 30),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 1,
                        color: AppTheme.softRose.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.softRose,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        width: 42,
                        height: 1,
                        color: AppTheme.softRose.withValues(alpha: 0.65),
                      ),
                    ],
                  ),

                  SizedBox(height: isCompact ? 18 : 24),

                  const Text(
                    'حيث تتحوّل الحِرفة إلى فنّ رقمي',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 10),

                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: const Text(
                      'منصة راقية تجمع المصممين وعشّاق التطريز الرقمي، '
                      'لتكتشف تصاميم استثنائية صُنعت بدقّة، وشغف، وهوية لا تُنسى.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5,
                        color: AppTheme.mutedIvory,
                        height: 1.9,
                      ),
                    ),
                  ),

                  SizedBox(height: isCompact ? 30 : 42),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 250),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.richBurgundy,
                          foregroundColor: AppTheme.warmIvory,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: AppTheme.softRose.withValues(alpha: 0.38),
                            ),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'تفضّل بالدخول',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isCompact ? 28 : 38),

                  const Text(
                    'DIGITAL EMBROIDERY · DESIGN · CRAFT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.softRose,
                      letterSpacing: 2.4,
                    ),
                  ),

                  const Spacer(flex: 3),

                  const Text(
                    'TRACÉ RAFFINÉ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'CormorantGaramond',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.mutedText,
                      letterSpacing: 2.8,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
