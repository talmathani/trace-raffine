import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني.');
      return;
    }

    if (password.isEmpty) {
      _showMessage('أدخل كلمة المرور.');
      return;
    }

    if (password.length < 6) {
      _showMessage('كلمة المرور يجب أن تكون 6 أحرف على الأقل.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('كلمتا المرور غير متطابقتين.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _authRepository.sendEmailVerification();

      if (!mounted) {
        return;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'Firebase registration exception: '
        'code=${error.code}, message=${error.message}',
      );

      String message = 'تعذر إنشاء الحساب حاليًا.';

      switch (error.code) {
        case 'email-already-in-use':
          message = 'هذا البريد الإلكتروني مستخدم بالفعل.';
          break;

        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;

        case 'weak-password':
          message = 'كلمة المرور ضعيفة. استخدم كلمة مرور أقوى.';
          break;

        case 'operation-not-allowed':
          message = 'تسجيل الدخول بالبريد الإلكتروني غير مفعّل في Firebase.';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بخدمة Firebase. تحقق من الإنترنت.';
          break;

        case 'too-many-requests':
          message = 'تم تنفيذ محاولات كثيرة. انتظر قليلًا ثم حاول مرة أخرى.';
          break;
      }

      _showMessage(message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Unexpected registration error: $error');

      _showMessage('حدث خطأ أثناء إنشاء الحساب أو إرسال رسالة التفعيل.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 54,
                    color: AppTheme.softRose,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'أنشئ حسابك للبدء في استخدام TRACÉ RAFINÉ.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: _inputDecoration(
                      label: 'البريد الإلكتروني',
                      icon: Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: _inputDecoration(
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) {
                      if (!_isLoading) {
                        _register();
                      }
                    },
                    decoration: _inputDecoration(
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_reset_outlined,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'إنشاء الحساب',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                    child: const Text('لدي حساب بالفعل'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthRepository _authRepository = AuthRepository();

  bool _isChecking = false;
  bool _isSending = false;

  Future<void> _checkVerification() async {
    if (_isChecking) {
      return;
    }

    setState(() {
      _isChecking = true;
    });

    try {
      final verified = await _authRepository.reloadAndCheckEmailVerification();

      if (!mounted) {
        return;
      }

      if (verified) {
        _showMessage('تم تأكيد البريد الإلكتروني بنجاح.');

        await Future<void>.delayed(const Duration(milliseconds: 500));

        if (!mounted) {
          return;
        }

        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showMessage(
          'لم يتم تأكيد البريد بعد. افتح رسالة التفعيل ثم حاول مرة أخرى.',
        );
      }
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Email verification check: '
        'code=${error.code}, message=${error.message}',
      );

      if (mounted) {
        _showMessage('تعذر التحقق من البريد حاليًا. حاول مرة أخرى.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    if (_isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await _authRepository.sendEmailVerification();

      if (!mounted) {
        return;
      }

      _showMessage('تم إرسال رسالة تفعيل جديدة إلى بريدك الإلكتروني.');
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Email verification resend: '
        'code=${error.code}, message=${error.message}',
      );

      if (!mounted) {
        return;
      }

      String message = 'تعذر إرسال رسالة التفعيل.';

      switch (error.code) {
        case 'too-many-requests':
          message = 'تم إرسال عدة رسائل. انتظر قليلًا ثم حاول مرة أخرى.';
          break;

        case 'network-request-failed':
          message = 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى.';
          break;

        case 'user-disabled':
          message = 'هذا الحساب معطل.';
          break;
      }

      _showMessage(message);
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    await _authRepository.signOut();

    if (!mounted) {
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final email = _authRepository.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد البريد الإلكتروني'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  const SizedBox(height: 35),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.obsidian,
                      border: Border.all(
                        color: AppTheme.softRose.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Icon(
                      Icons.mark_email_unread_outlined,
                      size: 48,
                      color: AppTheme.softRose,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'تحقق من بريدك الإلكتروني',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'أرسلنا رسالة تفعيل إلى:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'افتح بريدك الإلكتروني واضغط رابط التفعيل، ثم ارجع إلى التطبيق واضغط «تحقق من التفعيل».',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      height: 1.8,
                      color: AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isChecking ? null : _checkVerification,
                      icon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.verified_outlined),
                      label: Text(
                        _isChecking ? 'جارٍ التحقق...' : 'تحقق من التفعيل',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isSending ? null : _resendVerification,
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        _isSending
                            ? 'جارٍ الإرسال...'
                            : 'إعادة إرسال رسالة التفعيل',
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
