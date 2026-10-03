import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_app_bar.dart';
import 'package:trace_raffine/core/ui/maison_surface.dart';
import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/domain/repositories/user_profile_repository.dart';
import 'package:trace_raffine/features/auth/domain/repositories/auth_repository.dart';
import 'package:trace_raffine/features/profile/services/profile_session_service.dart';
import 'package:trace_raffine/features/profile/domain/usecases/update_user_profile.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _firstNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _obscurePassword = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final session = context.read<ProfileSessionService>();
      final profile = await session.loadCurrentProfile();
      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _loading = false;
          _loadError =
              'تعذر تحميل بيانات الحساب. سجّل الدخول من جديد ثم حاول مرة أخرى.';
        });
        return;
      }

      final nameParts = profile.displayName
          .trim()
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .toList();
      _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      _fatherNameController.text = nameParts.length > 1 ? nameParts[1] : '';
      _surnameController.text = nameParts.length > 2
          ? nameParts.sublist(2).join(' ')
          : '';
      _phoneController.text = profile.phone ?? '';
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = _friendlyLoadError(error);
      });
    }
  }

  String _friendlyLoadError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('401') ||
        text.contains('unauthorized') ||
        text.contains('missing scope') ||
        text.contains('user_unauthorized')) {
      return 'انتهت جلسة الدخول. سجّل الدخول من جديد ثم افتح بيانات الحساب.';
    }
    if (text.contains('created_at') || text.contains('createdat')) {
      return 'بيانات الحساب غير مكتملة في قاعدة البيانات.';
    }
    return 'تعذر تحميل بيانات الحساب حالياً. حاول مرة أخرى.';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final session = context.read<ProfileSessionService>();
    final profile = session.currentProfile;
    final auth = context.read<AuthRepository>();
    final profileRepository = context.read<UserProfileRepository>();
    if (profile == null || auth.currentUser == null) {
      _message('تعذر تحميل بيانات الحساب.');
      return;
    }

    final firstName = _firstNameController.text.trim();
    final fatherName = _fatherNameController.text.trim();
    final surname = _surnameController.text.trim();
    final name = [
      firstName,
      fatherName,
      surname,
    ].where((part) => part.isNotEmpty).join(' ');
    final phone = _phoneController.text.trim();
    final previousPhone = (profile.phone ?? '').trim();

    if (firstName.isEmpty || fatherName.isEmpty || surname.isEmpty) {
      _message('أدخل الاسم الأول واسم الأب واللقب.');
      return;
    }

    final phoneChanged = phone != previousPhone;
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (currentPassword.isEmpty) {
      _message('أدخل كلمة المرور الحالية.');
      return;
    }
    if (phoneChanged) {
      final normalized = phone.replaceAll(RegExp(r'[\s()-]'), '');
      if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(normalized)) {
        _message('رقم الهاتف يجب أن يكون بالصيغة الدولية مثل +9677XXXXXXXX.');
        return;
      }
      if (_currentPasswordController.text.isEmpty) {
        _message('أدخل كلمة المرور الحالية لتغيير رقم الهاتف.');
        return;
      }
    }

    if (newPassword.isEmpty ||
        confirmPassword.isEmpty ||
        newPassword != confirmPassword) {
      _message('أدخل كلمة المرور الجديدة وتأكيدها بشكل متطابق.');
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = profile.copyWith(
        displayName: name,
        phone: phoneChanged
            ? phone.replaceAll(RegExp(r'[\s()-]'), '')
            : previousPhone,
      );
      await auth.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await UpdateUserProfile(profileRepository)(updated);

      if (phoneChanged) {
        await auth.updatePhone(
          phone: phone.replaceAll(RegExp(r'[\s()-]'), ''),
          password: currentPassword,
        );
      }

      await session.loadCurrentProfile();
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _message('تم حفظ بيانات الحساب.');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      _message(_friendlyError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('phone') || text.contains('password')) {
      return 'تعذر تحديث رقم الهاتف. تحقق من الرقم وكلمة المرور الحالية.';
    }
    return 'تعذر حفظ بيانات الحساب. حاول مرة أخرى.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.burgundyBlack,
          content: Text(
            value,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: AppTheme.warmIvory,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.read<ProfileSessionService>().currentProfile;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      appBar: const MaisonAppBar(title: 'تعديل الملف الشخصي'),
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
                const _ProfileLoading()
              else if (_loadError != null)
                _ProfileUnavailable(message: _loadError!, onRetry: _loadProfile)
              else if (profile == null)
                _ProfileUnavailable(
                  message: 'لا تتوفر بيانات الحساب حالياً.',
                  onRetry: _loadProfile,
                )
              else ...[
                _buildIntro(profile),
                const SizedBox(height: 28),
                _buildField(
                  controller: _firstNameController,
                  label: 'الاسم الأول',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 22),
                _buildField(
                  controller: _fatherNameController,
                  label: 'اسم الأب',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.name,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 22),
                _buildField(
                  controller: _surnameController,
                  label: 'اللقب',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.name,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 22),
                _buildReadOnlyField(
                  label: 'البريد الإلكتروني',
                  value: profile.email ?? '—',
                  icon: Icons.mail_outline_rounded,
                ),
                const SizedBox(height: 22),
                _buildField(
                  controller: _phoneController,
                  label: 'رقم الهاتف الدولي',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  onTap: _showCountryPicker,
                ),
                const SizedBox(height: 14),
                Text(
                  'تغيير رقم الهاتف يتطلب كلمة المرور الحالية.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 12,
                    color: AppTheme.mutedIvory.withValues(alpha: 0.70),
                  ),
                ),
                const SizedBox(height: 22),
                _buildPasswordField(
                  controller: _currentPasswordController,
                  label: 'كلمة المرور الحالية',
                ),
                const SizedBox(height: 18),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'كلمة المرور الجديدة',
                ),
                const SizedBox(height: 18),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'تأكيد كلمة المرور الجديدة',
                ),
                const SizedBox(height: 30),
                _buildSaveButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(dynamic profile) {
    return MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'مساحتك الشخصية',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.role == UserRole.designer ? 'حساب المصمم' : 'حساب العميل',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 13,
                color: AppTheme.softRose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      showSearch: true,
      useSafeArea: true,
      onSelect: (country) {
        final value = _phoneController.text.trim();
        final national = value.replaceFirst(RegExp(r'^\\+[0-9]+'), '');
        _phoneController.text = '+${country.phoneCode}$national';
      },
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextDirection textDirection = TextDirection.ltr,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: textDirection,
      onTap: onTap,
      style: const TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      cursorColor: AppTheme.softRose,
      decoration: _decoration(label, icon),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: _decoration(label, icon),
      child: Text(
        value,
        style: const TextStyle(
          fontFamily: AppTheme.fontArabic,
          color: AppTheme.mutedIvory,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      obscureText: _obscurePassword,
      textDirection: TextDirection.ltr,
      style: const TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      cursorColor: AppTheme.softRose,
      decoration: _decoration(label, Icons.lock_outline_rounded).copyWith(
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppTheme.softRose.withValues(alpha: 0.68),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.divider.withValues(alpha: 0.72)),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.divider.withValues(alpha: 0.72)),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: AppTheme.softRose, width: 1.1),
      ),
      labelText: label,
      labelStyle: TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.mutedIvory.withValues(alpha: 0.82),
      ),
      floatingLabelStyle: const TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.softRose,
      ),
      prefixIcon: Icon(
        icon,
        size: 22,
        color: AppTheme.softRose.withValues(alpha: 0.68),
      ),
    );
  }

  Widget _buildSaveButton() {
    return EditorialButton(
      label: 'حفظ التغييرات',
      onPressed: _saving ? null : _save,
      loading: _saving,
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();

  @override
  Widget build(BuildContext context) {
    return MaisonSurface(
      color: AppTheme.burgundyBlack,
      radius: AppTheme.editorialPanelRadius,
      child: const Padding(
        padding: EdgeInsets.all(28),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.softRose),
        ),
      ),
    );
  }
}

class _ProfileUnavailable extends StatelessWidget {
  const _ProfileUnavailable({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            const SizedBox(height: 18),
            EditorialButton(label: 'إعادة المحاولة', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
