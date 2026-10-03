import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_event.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import '../favorites/favorites_screen.dart';
import '../orders/orders_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/manager_chat_screen.dart';
import '../profile/profile_details_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: MaisonAppBar(title: 'حسابي'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsiveContentMaxWidth,
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              context.responsiveHorizontalPadding,
              context.isCompact ? 18 : 24,
              context.responsiveHorizontalPadding,
              40,
            ),
            children: [
              _buildNavigationSurface(
                context,
                icon: Icons.person_outline_rounded,
                label: 'بيانات الحساب',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileDetailsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavigationSurface(
                context,
                icon: Icons.favorite_outline,
                label: 'المفضلة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavigationSurface(
                context,
                icon: Icons.receipt_long_outlined,
                label: 'طلباتي',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavigationSurface(
                context,
                icon: Icons.notifications_none_outlined,
                label: 'الإشعارات',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavigationSurface(
                context,
                icon: Icons.chat_bubble_outline_rounded,
                label: 'محادثة الإدارة',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManagerChatScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildNavigationSurface(
                context,
                icon: Icons.logout_rounded,
                label: 'تسجيل الخروج',
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildNavigationSurface(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return MaisonSurface(
      radius: AppTheme.editorialPanelRadius,
      color: AppTheme.burgundyBlack,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppTheme.editorialPanelRadius),
        hoverColor: AppTheme.richBurgundy.withValues(alpha: 0.16),
        splashColor: AppTheme.softRose.withValues(alpha: 0.10),
        highlightColor: AppTheme.roseBurgundy.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 16, 18),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(icon, size: 22, color: AppTheme.softRose),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warmIvory,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.chevron_left_rounded,
                size: 22,
                color: AppTheme.mutedIvory,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
