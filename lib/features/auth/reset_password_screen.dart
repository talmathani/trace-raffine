import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_back_button.dart';
import 'package:trace_raffine/features/auth/domain/repositories/auth_repository.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:trace_raffine/features/auth/presentation/bloc/auth_event.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.userId,
    required this.secret,
    this.onCompleted,
    this.onBack,
  });

  final String userId;
  final String secret;
  final VoidCallback? onCompleted;
  final VoidCallback? onBack;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _completed = false;

  AuthRepository get _repository => context.read<AuthRepository>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validate() {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      return 'كلمة المرور يجب أن تحتوي على 8 أحرف أو أكثر.';
    }

    if (password != confirm) {
      return 'تأكيد كلمة المرور غير مطابق.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final error = _validate();
    if (error != null) {
      _showMessage(error);
      return;
    }

    if (_loading || _completed) {
      return;
    }

    setState(() => _loading = true);

    try {
      await _repository.confirmPasswordRecovery(
        userId: widget.userId,
        secret: widget.secret,
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
        _completed = true;
      });

      _showMessage('تم تغيير كلمة المرور بنجاح. يمكنك تسجيل الدخول الآن.');

      context.read<AuthBloc>().add(const AuthStarted());
      widget.onCompleted?.call();
    } catch (error) {
      if (!mounted) return;

      setState(() => _loading = false);

      final text = error.toString().toLowerCase();
      if (text.contains('expired') || text.contains('invalid')) {
        _showMessage(
          'رابط الاسترداد منتهي أو غير صالح. اطلب رابطاً جديداً من شاشة تسجيل الدخول.',
        );
      } else {
        _showMessage('تعذر تغيير كلمة المرور حالياً. حاول مرة أخرى.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final expanded = width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/LOG IN.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0.0, 0.0),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppTheme.obsidian.withValues(alpha: 0.86),
                      AppTheme.burgundyBlack.withValues(alpha: 0.72),
                      AppTheme.deepBurgundy.withValues(alpha: 0.34),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 72 : 22,
                vertical: expanded ? 56 : 30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      expanded ? 56 : 24,
                      expanded ? 54 : 34,
                      expanded ? 56 : 24,
                      expanded ? 48 : 34,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.burgundyBlack.withValues(alpha: 0.78),
                      border: Border.all(
                        color: AppTheme.softRose.withValues(alpha: 0.16),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 48,
                          spreadRadius: 2,
                          offset: Offset(0, 20),
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'TRACÉ RAFFINÉ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontEditorial,
                            color: AppTheme.warmIvory,
                            fontSize: expanded ? 30 : 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: expanded ? 5.0 : 3.8,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Container(
                            width: 44,
                            height: 1,
                            color: AppTheme.softRose.withValues(alpha: 0.58),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _completed
                              ? 'تم تحديث كلمة المرور'
                              : 'إنشاء كلمة مرور جديدة',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            color: AppTheme.warmIvory,
                            fontSize: expanded ? 34 : 28,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _completed
                              ? 'أصبح حسابك جاهزاً. استخدم كلمة المرور الجديدة لتسجيل الدخول.'
                              : 'أدخل كلمة مرور جديدة لحسابك. هذا الرابط صالح لمدة محدودة.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            color: AppTheme.mutedIvory,
                            fontSize: 14,
                            height: 1.9,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (!_completed) ...[
                          _PasswordField(
                            controller: _passwordController,
                            label: 'كلمة المرور الجديدة',
                            obscureText: _obscurePassword,
                            enabled: !_loading,
                            onToggle: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _PasswordField(
                            controller: _confirmController,
                            label: 'تأكيد كلمة المرور',
                            obscureText: _obscureConfirm,
                            enabled: !_loading,
                            onSubmitted: (_) => _submit(),
                            onToggle: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'الحد الأدنى 8 أحرف.',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: AppTheme.fontArabic,
                              color: AppTheme.mutedIvory.withValues(
                                alpha: 0.68,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            height: 56,
                            child: EditorialButton(
                              onPressed: _loading ? null : _submit,
                              loading: _loading,
                              label: 'حفظ كلمة المرور',
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            height: 56,
                            child: EditorialButton(
                              onPressed: widget.onCompleted,
                              label: 'العودة إلى تسجيل الدخول',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 18,
            start: 20,
            child: MaisonBackButton(
              onPressed: widget.onBack ?? widget.onCompleted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.enabled,
    required this.onToggle,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final bool enabled;
  final VoidCallback onToggle;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      textDirection: TextDirection.ltr,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontFamily: 'Cairo',
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: AppTheme.mutedIvory.withValues(alpha: 0.82),
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: enabled ? onToggle : null,
          tooltip: obscureText ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
      ),
    );
  }
}
