import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../../../app/tr_admin_theme.dart';
import '../../../core/config/appwrite_services.dart';

final class AdminRecoveryRequestPage extends StatefulWidget {
  const AdminRecoveryRequestPage({super.key});

  @override
  State<AdminRecoveryRequestPage> createState() =>
      _AdminRecoveryRequestPageState();
}

final class _AdminRecoveryRequestPageState
    extends State<AdminRecoveryRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _loading = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestRecovery() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _success = false;
    });

    try {
      await AppwriteServices.account.createRecovery(
        email: _emailController.text.trim(),
        url: 'http://localhost:55941/reset-password',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _success = true;
        _message = 'تم إرسال رابط الاسترداد إلى بريدك الإلكتروني.';
      });
    } on AppwriteException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _message = error.message ?? 'تعذر إرسال رابط الاسترداد.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _message = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TRAdminTheme.obsidian,
        appBar: AppBar(
          backgroundColor: TRAdminTheme.deepBurgundy,
          foregroundColor: TRAdminTheme.warmIvory,
          elevation: 0,
          title: const Text('استرداد الحساب'),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: TRAdminTheme.deepBurgundy,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: TRAdminTheme.roseBurgundy.withValues(
                        alpha: 0.38,
                      ),
                    ),
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
                          'استرداد حساب الإدارة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TRAdminTheme.warmIvory,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'أدخل البريد الإلكتروني المرتبط بحساب الإدارة لإرسال رابط آمن لإعادة تعيين كلمة المرور.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TRAdminTheme.mutedIvory,
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: TRAdminTheme.warmIvory,
                          ),
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'admin@example.com',
                            labelStyle: const TextStyle(
                              color: TRAdminTheme.roseBurgundy,
                            ),
                            prefixIcon: const Icon(
                              Icons.alternate_email_rounded,
                              color: TRAdminTheme.roseBurgundy,
                            ),
                            filled: true,
                            fillColor: TRAdminTheme.obsidian,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';

                            if (email.isEmpty) {
                              return 'أدخل البريد الإلكتروني.';
                            }

                            if (!email.contains('@') ||
                                !email.contains('.')) {
                              return 'أدخل بريدًا إلكترونيًا صحيحًا.';
                            }

                            return null;
                          },
                        ),
                        if (_message != null) ...[
                          const SizedBox(height: 18),
                          Text(
                            _message!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _success
                                  ? TRAdminTheme.warmIvory
                                  : TRAdminTheme.errorColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed: _loading ? null : _requestRecovery,
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
                                    'إرسال رابط الاسترداد',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('العودة إلى تسجيل الدخول'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

