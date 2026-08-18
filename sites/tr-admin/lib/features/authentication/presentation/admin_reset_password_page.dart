import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../../../app/tr_admin_theme.dart';
import '../../../core/config/appwrite_services.dart';

final class AdminResetPasswordPage extends StatefulWidget {
  const AdminResetPasswordPage({
    super.key,
    this.userId,
    this.secret,
  });

  final String? userId;
  final String? secret;

  @override
  State<AdminResetPasswordPage> createState() =>
      _AdminResetPasswordPageState();
}

final class _AdminResetPasswordPageState
    extends State<AdminResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = widget.userId?.trim();
    final secret = widget.secret?.trim();

    if (userId == null ||
        userId.isEmpty ||
        secret == null ||
        secret.isEmpty) {
      setState(() {
        _message = 'رابط إعادة التعيين غير صالح أو منتهي الصلاحية.';
        _success = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _success = false;
    });

    try {
      await AppwriteServices.account.updateRecovery(
        userId: userId,
        secret: secret,
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _success = true;
        _message = 'تم تحديث كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.';
      });
    } on AppwriteException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _message =
            error.message ?? 'تعذر تحديث كلمة المرور.';
        _success = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _message = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Cairo',
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: TRAdminTheme.obsidian,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 460,
                  ),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: TRAdminTheme.deepBurgundy,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TRAdminTheme.roseBurgundy.withValues(
            alpha: 0.38,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: TRAdminTheme.obsidian.withValues(
              alpha: 0.38,
            ),
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
            const Icon(
              Icons.lock_reset_rounded,
              size: 58,
              color: TRAdminTheme.roseBurgundy,
            ),
            const SizedBox(height: 22),
            const Text(
              'إعادة تعيين كلمة المرور',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TRAdminTheme.warmIvory,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'أنشئ كلمة مرور جديدة وآمنة لحساب الإدارة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TRAdminTheme.mutedIvory,
                fontSize: 13,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 28),
            _buildPasswordField(),
            const SizedBox(height: 18),
            _buildConfirmPasswordField(),
            if (_message != null) ...[
              const SizedBox(height: 18),
              _buildMessage(),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton(
                onPressed: _loading || _success
                    ? null
                    : _resetPassword,
                style: FilledButton.styleFrom(
                  backgroundColor: TRAdminTheme.richBurgundy,
                  foregroundColor: TRAdminTheme.warmIvory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: TRAdminTheme.warmIvory,
                        ),
                      )
                    : const Text(
                        'تحديث كلمة المرور',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              child: const Text(
                'العودة إلى تسجيل الدخول',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(
        color: TRAdminTheme.warmIvory,
      ),
      decoration: _inputDecoration(
        label: 'كلمة المرور الجديدة',
        icon: Icons.lock_outline_rounded,
        obscure: _obscurePassword,
        onToggle: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
      validator: (value) {
        final password = value ?? '';

        if (password.isEmpty) {
          return 'أدخل كلمة المرور الجديدة.';
        }

        if (password.length < 8) {
          return 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل.';
        }

        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      style: const TextStyle(
        color: TRAdminTheme.warmIvory,
      ),
      decoration: _inputDecoration(
        label: 'تأكيد كلمة المرور',
        icon: Icons.verified_user_outlined,
        obscure: _obscureConfirmPassword,
        onToggle: () {
          setState(() {
            _obscureConfirmPassword =
                !_obscureConfirmPassword;
          });
        },
      ),
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return 'أكد كلمة المرور.';
        }

        if (value != _passwordController.text) {
          return 'كلمتا المرور غير متطابقتين.';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: TRAdminTheme.roseBurgundy,
      ),
      prefixIcon: Icon(
        icon,
        color: TRAdminTheme.roseBurgundy,
      ),
      suffixIcon: IconButton(
        tooltip: obscure
            ? 'إظهار كلمة المرور'
            : 'إخفاء كلمة المرور',
        onPressed: onToggle,
        icon: Icon(
          obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: TRAdminTheme.roseBurgundy,
        ),
      ),
      filled: true,
      fillColor: TRAdminTheme.obsidian,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TRAdminTheme.obsidian,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _success
              ? TRAdminTheme.roseBurgundy
              : TRAdminTheme.errorColor,
        ),
      ),
      child: Text(
        _message!,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _success
              ? TRAdminTheme.warmIvory
              : TRAdminTheme.errorColor,
          height: 1.5,
        ),
      ),
    );
  }
}
