import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../onboarding/services/agreement_service.dart';
import '../onboarding/widgets/role_agreement_dialog.dart';
import '../shells/administration_shell.dart';
import '../shells/customer_shell.dart';
import '../shells/designer_shell.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_screen.dart';

enum UserRole { customer, designer, administration }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _rememberAccountKey = 'remember_account';
  static const String _savedEmailKey = 'saved_login_email';
  static const String _savedRoleKey = 'saved_login_role';

  AuthRepository get _authRepository => context.read<AuthRepository>();
  final AgreementService _agreementService = AgreementService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  bool _obscurePassword = true;
  bool _rememberAccount = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedAccount();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedAccount() async {
    final preferences = await SharedPreferences.getInstance();

    final remember = preferences.getBool(_rememberAccountKey) ?? true;

    final savedEmail = preferences.getString(_savedEmailKey);

    final savedRole = preferences.getString(_savedRoleKey);

    if (!mounted) {
      return;
    }

    setState(() {
      _rememberAccount = remember;

      if (savedEmail != null && savedEmail.trim().isNotEmpty) {
        _emailController.text = savedEmail;
      }

      if (savedRole != null) {
        _selectedRole = UserRole.values.firstWhere(
          (role) => role.name == savedRole,
          orElse: () => UserRole.customer,
        );
      }
    });
  }

  Future<void> _saveRememberedAccount() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_rememberAccountKey, _rememberAccount);

    if (_rememberAccount) {
      await preferences.setString(_savedEmailKey, _emailController.text.trim());

      await preferences.setString(_savedRoleKey, _selectedRole.name);
    } else {
      await preferences.remove(_savedEmailKey);
      await preferences.remove(_savedRoleKey);
    }
  }

  Future<void> _showAgreementIfRequired() async {
    final user = _authRepository.currentUser;

    if (user == null || !mounted) {
      return;
    }

    final role = _selectedRole.name;

    final accepted = await _agreementService.hasAccepted(
      uid: user.id,
      role: role,
    );

    if (accepted || !mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return RoleAgreementDialog(
          role: _selectedRole,
          onAccepted: () async {
            await _agreementService.markAccepted(uid: user.id, role: role);

            if (!mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _navigateToRoleShell() {
    if (!mounted) {
      return;
    }

    final Widget destination;

    switch (_selectedRole) {
      case UserRole.customer:
        destination = const CustomerShell();
        break;

      case UserRole.designer:
        destination = const DesignerShell();
        break;

      case UserRole.administration:
        destination = const AdministrationShell();
        break;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => destination));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني وكلمة المرور أولاً.');
      return;
    }

    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveRememberedAccount();

      await _showAgreementIfRequired();

      if (!mounted) {
        return;
      }

      _navigateToRoleShell();
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'FirebaseAuthException: '
        'code=${error.code}, '
        'message=${error.message}',
      );

      String message;

      switch (error.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          break;

        case 'invalid-email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;

        case 'user-disabled':
          message = 'هذا الحساب معطّل حالياً.';
          break;

        case 'too-many-requests':
          message = 'تمت محاولات كثيرة. حاول مرة أخرى لاحقاً.';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بخدمة Firebase.';
          break;

        default:
          message = 'تعذر تسجيل الدخول حالياً. حاول مرة أخرى.';
      }

      _showMessage(message);
    } catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint('Unexpected login error: $error');

      _showMessage('حدث خطأ غير متوقع أثناء تسجيل الدخول.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final initialEmail = _emailController.text.trim();

    final controller = TextEditingController(text: initialEmail);

    bool loading = false;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: !loading,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                backgroundColor: AppTheme.obsidian,
                title: const Text(
                  'استرداد كلمة المرور',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: AppTheme.warmIvory,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني.',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: AppTheme.mutedIvory,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      enabled: !loading,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.of(dialogContext).pop();
                          },
                    child: const Text('إلغاء'),
                  ),
                  ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final email = controller.text.trim();

                            if (email.isEmpty) {
                              _showMessage('اكتب بريدك الإلكتروني أولاً.');
                              return;
                            }

                            setDialogState(() {
                              loading = true;
                            });

                            try {
                              await _authRepository.sendPasswordResetEmail(
                                email: email,
                              );

                              if (!mounted) {
                                return;
                              }

                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }

                              _showMessage(
                                'تم إرسال رابط استرداد كلمة المرور إلى بريدك الإلكتروني.',
                              );
                            } on FirebaseAuthException catch (error) {
                              if (!mounted) {
                                return;
                              }

                              setDialogState(() {
                                loading = false;
                              });

                              debugPrint(
                                'Password reset exception: '
                                'code=${error.code}, '
                                'message=${error.message}',
                              );

                              String message = 'تعذر إرسال رسالة الاسترداد.';

                              switch (error.code) {
                                case 'invalid-email':
                                  message = 'صيغة البريد الإلكتروني غير صحيحة.';
                                  break;

                                case 'user-not-found':
                                  message = 'لا يوجد حساب مرتبط بهذا البريد.';
                                  break;

                                case 'too-many-requests':
                                  message =
                                      'تم تجاوز عدد المحاولات. حاول لاحقاً.';
                                  break;

                                case 'network-request-failed':
                                  message = 'تعذر الاتصال بخدمة Firebase.';
                                  break;
                              }

                              _showMessage(message);
                            } catch (error) {
                              if (!mounted) {
                                return;
                              }

                              setDialogState(() {
                                loading = false;
                              });

                              debugPrint(
                                'Unexpected password reset error: '
                                '$error',
                              );

                              _showMessage(
                                'حدث خطأ غير متوقع أثناء الاسترداد.',
                              );
                            }
                          },
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إرسال الرابط'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _selectRole(UserRole role) {
    if (_isLoading || role == _selectedRole) {
      return;
    }

    setState(() {
      _selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= 850;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 60 : 24,
              vertical: 28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _buildBrandPanel()),
                        const SizedBox(width: 70),
                        Expanded(child: _buildLoginPanel()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildCompactBrandHeader(),
                        const SizedBox(height: 34),
                        _buildLoginPanel(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRACÉ RAFINÉ',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 38,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 14),
        Container(width: 72, height: 1, color: AppTheme.softRose),
        const SizedBox(height: 30),
        const Text(
          'مرحباً بك\nفي عالم الحِرفة الرقمية.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'مساحة راقية تجمع الإبداع، الدقّة، '
          'والتصميم في تجربة واحدة صُممت لعشّاق التطريز الرقمي.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppTheme.mutedIvory,
            height: 1.9,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'DIGITAL EMBROIDERY · DESIGN · CRAFT',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.softRose,
            letterSpacing: 2.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBrandHeader() {
    return Column(
      children: [
        const Text(
          'TRACÉ RAFINÉ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(width: 52, height: 1, color: AppTheme.softRose),
      ],
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.obsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.divider),
        boxShadow: const [
          BoxShadow(
            blurRadius: 30,
            offset: Offset(0, 12),
            color: Colors.black26,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'تسجيل الدخول',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.warmIvory,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختر نوع الحساب ثم أدخل بيانات الدخول.',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: AppTheme.mutedText,
            ),
          ),
          const SizedBox(height: 22),
          _buildRoleSelector(),
          const SizedBox(height: 22),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textDirection: TextDirection.ltr,
            enabled: !_isLoading,
            onSubmitted: (_) {
              if (!_isLoading) {
                _submit();
              }
            },
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? 'إظهار كلمة المرور'
                    : 'إخفاء كلمة المرور',
                onPressed: _isLoading
                    ? null
                    : () {
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
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: _rememberAccount,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _rememberAccount = value ?? false;
                        });
                      },
              ),
              const Expanded(
                child: Text(
                  'تذكّر الحساب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.mutedIvory,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading ? null : _forgotPassword,
                child: const Text('هل نسيت كلمة المرور؟'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('متابعة'),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, size: 19),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Flexible(
                child: Text(
                  'ليس لديك حساب؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppTheme.mutedText,
                  ),
                ),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                child: const Text('إنشاء حساب'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.obsidian,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleItem(
              role: UserRole.customer,
              label: 'العميل',
              icon: Icons.shopping_bag_outlined,
            ),
          ),
          Expanded(
            child: _buildRoleItem(
              role: UserRole.designer,
              label: 'المصمم',
              icon: Icons.draw_outlined,
            ),
          ),
          Expanded(
            child: _buildRoleItem(
              role: UserRole.administration,
              label: 'الإدارة',
              icon: Icons.admin_panel_settings_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem({
    required UserRole role,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.obsidian : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: AppTheme.softRose) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 21,
              color: selected ? AppTheme.softRose : AppTheme.mutedText,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppTheme.warmIvory : AppTheme.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


