import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/admin_auth_controller.dart';
import '../presentation/admin_auth_state.dart';
import '../../../app/tr_admin_theme.dart';

import '../../../core/utils/admin_local_storage.dart';

final class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

final class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool _rememberAccount = true;

  static const _burgundyBlack = TRAdminTheme.obsidian;
  static const _deepBurgundy = TRAdminTheme.deepBurgundy;
  static const _softBurgundy = TRAdminTheme.roseBurgundy;
  static const _warmIvory = TRAdminTheme.warmIvory;
  static const _mutedIvory = TRAdminTheme.mutedIvory;
  static const _fieldBorder = TRAdminTheme.divider;

  @override
  void initState() {
    super.initState();
    _loadRememberedAccount();
  }

  Future<void> _loadRememberedAccount() async {
    final email = await AdminLocalStorage.getRememberedEmail();

    if (!mounted || email == null || email.isEmpty) {
      return;
    }

    _emailController.text = email;

    setState(() {
      _rememberAccount = true;
    });
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(adminAuthControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    final authState = ref.read(adminAuthControllerProvider);

    if (authState.isAuthenticated) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/dashboard',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthControllerProvider);

    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(
          fontFamily: 'Cairo',
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _burgundyBlack,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _buildLoginCard(context, authState),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(
    BuildContext context,
    AdminAuthState authState,
  ) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _deepBurgundy,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _softBurgundy.withValues(alpha: 0.38),
        ),
        boxShadow: [
          BoxShadow(
            color: TRAdminTheme.obsidian.withValues(alpha: 0.38),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBrandHeader(),
            const SizedBox(height: 30),
            const Text(
              'هلا بشيخ المصممين',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _warmIvory,
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'هلا بك يا عيني و يا رمش عيني',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TRAdminTheme.roseBurgundy,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'دخول الإدارة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _warmIvory,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'سجّل دخولك للوصول إلى لوحة إدارة TRACÉ RAFFINÉ.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _mutedIvory,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            _buildEmailField(),
            const SizedBox(height: 18),
            _buildPasswordField(),
            _buildRememberAccount(),
            const SizedBox(height: 10),            if (authState.message != null &&
                authState.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              _buildMessage(authState),
            ],
            const SizedBox(height: 26),
            _buildLoginButton(authState),
            const SizedBox(height: 12),
            TextButton(onPressed: () => Navigator.of(context).pushNamed('/recovery'), child: const Text('استرداد الحساب')),
            const SizedBox(height: 26),
            _buildSecurityFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _burgundyBlack,
            border: Border.all(
              color: TRAdminTheme.roseBurgundy,
              width: 1.3,
            ),

          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo_burgundy.PNG',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return const Center(
                  child: Text(
                    'TR',
                    style: TextStyle(
                      color: TRAdminTheme.roseBurgundy,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TRACÉ RAFFINÉ',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _warmIvory,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'إدارة المنصة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: TRAdminTheme.roseBurgundy,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      textDirection: TextDirection.ltr,
      autofillHints: const [
        AutofillHints.username,
        AutofillHints.email,
      ],
      style: const TextStyle(color: _warmIvory),
      decoration: _inputDecoration(
        label: 'البريد الإلكتروني للإدارة',
        hint: 'admin@example.com',
        icon: Icons.alternate_email_rounded,
      ),
      validator: (value) {
        final email = value?.trim() ?? '';

        if (email.isEmpty) {
          return 'أدخل البريد الإلكتروني للإدارة.';
        }

        if (!email.contains('@') || !email.contains('.')) {
          return 'أدخل بريدًا إلكترونيًا صحيحًا.';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) => _submit(),
      style: const TextStyle(color: _warmIvory),
      decoration: _inputDecoration(
        label: 'كلمة المرور',
        hint: 'أدخل كلمة المرور',
        icon: Icons.lock_outline_rounded,
      ).copyWith(
        suffixIcon: IconButton(
          tooltip: _obscurePassword
              ? 'إظهار كلمة المرور'
              : 'إخفاء كلمة المرور',
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: TRAdminTheme.roseBurgundy,
          ),
        ),
      ),
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return 'أدخل كلمة المرور.';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _softBurgundy),
      hintStyle: const TextStyle(color: TRAdminTheme.mutedText),
      prefixIcon: Icon(
        icon,
        color: TRAdminTheme.roseBurgundy,
      ),
      filled: true,
      fillColor: _burgundyBlack,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: TRAdminTheme.roseBurgundy,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: TRAdminTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: TRAdminTheme.errorColor,
          width: 1.2,
        ),
      ),
    );
  }


  Widget _buildRememberAccount() {
    return Row(
      children: [
        Checkbox(
          value: _rememberAccount,
          onChanged: (value) {
            setState(() {
              _rememberAccount = value ?? false;
            });
          },
          activeColor: TRAdminTheme.roseBurgundy,
          checkColor: TRAdminTheme.warmIvory,
          side: BorderSide(
            color: TRAdminTheme.roseBurgundy.withValues(alpha: 0.65),
          ),
        ),
        const Expanded(
          child: Text(
            'تذكّر هذا الحساب على هذا الجهاز',
            style: TextStyle(
              color: TRAdminTheme.mutedIvory,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildMessage(AdminAuthState authState) {
    final isUnauthorized =
        authState.status == AdminAuthStatus.unauthorized;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isUnauthorized
            ? TRAdminTheme.deepBurgundy
            : TRAdminTheme.burgundyBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnauthorized
              ? _softBurgundy
              : TRAdminTheme.roseBurgundy,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isUnauthorized
                ? Icons.admin_panel_settings_outlined
                : Icons.error_outline_rounded,
            size: 20,
            color: isUnauthorized
                ? _softBurgundy
                : TRAdminTheme.softRose,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              authState.message!,
              style: TextStyle(
                color: isUnauthorized
                    ? _warmIvory
                    : TRAdminTheme.warmIvory,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(AdminAuthState authState) {
    final isLoading = authState.isLoading;

    return SizedBox(
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: TRAdminTheme.richBurgundy,
          foregroundColor: _warmIvory,
          disabledBackgroundColor: TRAdminTheme.deepBurgundy,
          disabledForegroundColor: TRAdminTheme.mutedIvory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _warmIvory,
                  ),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login_rounded),
                  SizedBox(width: 10),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityFooter() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: TRAdminTheme.roseBurgundy,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'بيئة إدارة محمية وآمنة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TRAdminTheme.mutedText,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
















