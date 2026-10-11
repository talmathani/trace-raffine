import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/features/profile/profile_edit_screen.dart';
import 'package:trace_raffine/features/profile/services/profile_session_service.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<ProfileSessionService>().loadCurrentProfile();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل بيانات الحساب حالياً. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileSessionService>().currentProfile;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: const MaisonAppBar(title: 'بيانات الحساب'),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsiveContentMaxWidth,
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              context.responsiveHorizontalPadding,
              context.isCompact ? 16 : 28,
              context.responsiveHorizontalPadding,
              48,
            ),
            children: [
              if (_loading)
                const _LoadingSurface()
              else if (_error != null)
                _UnavailableSurface(message: _error!, onRetry: _load)
              else if (profile == null)
                const _UnavailableSurface(
                  message: 'لا تتوفر بيانات الحساب حالياً.',
                )
              else ...[
                _buildHeader(profile.role),
                const SizedBox(height: 34),
                _buildInfo(
                  icon: Icons.person_outline,
                  label: 'الاسم الكامل',
                  value: profile.displayName.trim().isNotEmpty
                      ? profile.displayName.trim()
                      : '—',
                ),
                _buildRule(),
                _buildInfo(
                  icon: Icons.email_outlined,
                  label: 'البريد الإلكتروني',
                  value: profile.email ?? '—',
                  ltr: true,
                ),
                _buildRule(),
                _buildInfo(
                  icon: Icons.phone_outlined,
                  label: 'رقم الهاتف',
                  value: profile.phone?.isNotEmpty == true
                      ? profile.phone!
                      : 'غير مضاف',
                  ltr: true,
                ),
                _buildRule(),
                _buildInfo(
                  icon: Icons.badge_outlined,
                  label: 'نوع الحساب',
                  value: profile.role == UserRole.designer ? 'مصمم' : 'عميل',
                ),
                _buildRule(),
                _buildInfo(
                  icon: Icons.verified_user_outlined,
                  label: 'حالة الحساب',
                  value: profile.isCurrentlySuspended ? 'موقوف' : 'نشط',
                ),
                const SizedBox(height: 34),
                EditorialButton(
                  label: 'تعديل الملف الشخصي',
                  onPressed: () async {
                    final changed = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (_) => const ProfileEditScreen(),
                      ),
                    );
                    if (changed == true && mounted) await _load();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(UserRole role) {
    return MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مساحتك الشخصية',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              role == UserRole.designer ? 'حساب المصمم' : 'حساب العميل',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 12,
                color: AppTheme.mutedIvory.withValues(alpha: 0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: AppTheme.mutedIvory.withValues(alpha: 0.12),
      ),
    );
  }

  Widget _buildInfo({
    required String label,
    required String value,
    required IconData icon,
    bool ltr = false,
  }) {
    return MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 16),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(icon, size: 22, color: AppTheme.softRose),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 12,
                      color: AppTheme.mutedIvory.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    textDirection: ltr ? TextDirection.ltr : null,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontArabic,
                      fontSize: 16,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSurface extends StatelessWidget {
  const _LoadingSurface();

  @override
  Widget build(BuildContext context) {
    return const MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.softRose),
        ),
      ),
    );
  }
}

class _UnavailableSurface extends StatelessWidget {
  const _UnavailableSurface({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.warmIvory,
                fontSize: 16,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              EditorialButton(label: 'إعادة المحاولة', onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
