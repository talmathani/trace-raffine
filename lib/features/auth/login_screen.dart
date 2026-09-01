import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../onboarding/services/agreement_service.dart';
import '../onboarding/widgets/role_agreement_dialog.dart';
import '../profile/services/profile_session_service.dart';
import 'domain/repositories/auth_repository.dart';
import '../../domain/entities/user_role.dart';
import '../../core/security/role_policy.dart';
import 'domain/exceptions/auth_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'presentation/widgets/login_painters.dart';
import 'presentation/pages/register_screen.dart';

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

  ProfileSessionService get _profileSession =>
      context.read<ProfileSessionService>();
  final AgreementService _agreementService = AgreementService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  bool _obscurePassword = true;
  bool _rememberAccount = true;
  bool _isLoading = false;
  bool _loginCompleted = false;

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

    final profile = _profileSession.currentProfile;

    if (profile == null) {
      debugPrint('=== AGREEMENT: PROFILE NOT AVAILABLE ===');
      return;
    }

    final role = (_profileSession.activeRole ?? profile.role).name;

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
          role: _profileSession.activeRole ?? profile.role,
          onAccepted: () async {
            await _agreementService.markAccepted(
              uid: user.id,
              role: role,
            );

            if (!mounted) {
              return;
            }

            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('أدخل البريد الإلكتروني وكلمة المرور أولاً.');
      return;
    }

    if (_isLoading || _loginCompleted) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('=== LOGIN STEP 1: APPWRITE SIGN IN START ===');

      await _authRepository.signIn(email: email, password: password);

      debugPrint('=== LOGIN STEP 1: APPWRITE SIGN IN SUCCESS ===');

      _loginCompleted = true;

      debugPrint('=== LOGIN STEP 2: SAVE REMEMBERED ACCOUNT START ===');

      await _saveRememberedAccount();

      debugPrint('=== LOGIN STEP 2: SAVE REMEMBERED ACCOUNT SUCCESS ===');

      debugPrint('=== LOGIN STEP 2.5: LOAD PROFILE SESSION START ===');

      final profile = await _profileSession.loadCurrentProfile();

      if (profile == null) {
        throw AuthFailure(
          code: 'profile_not_found',
          message: 'تعذر تحميل ملف الحساب.',
        );
      }

      debugPrint(
        '=== LOGIN STEP 2.5: PROFILE LOADED '
        'role=${profile.role.name} '
        'id=${profile.id} ===',
      );

      final canUseSelectedRole = RolePolicy.canUseRole(
        email: profile.email ?? email,
        storedRole: profile.role,
        requestedRole: _selectedRole,
      );

      if (!canUseSelectedRole) {
        debugPrint(
          '=== LOGIN ROLE MISMATCH === '
          'selected=${_selectedRole.name} '
          'actual=${profile.role.name}',
        );

        await _authRepository.signOut();
        _profileSession.clear();
        _loginCompleted = false;

        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
        });

        final selectedLabel = _selectedRole == UserRole.designer
            ? 'المصممين'
            : 'العملاء';

        final actualLabel = profile.role == UserRole.designer
            ? 'مصمم'
            : 'عميل';

        _showMessage(
          'هذا الحساب مسجل كـ $actualLabel. '
          'لا يمكن الدخول من قسم $selectedLabel.',
        );

        return;
      }

      _profileSession.setActiveRole(
        RolePolicy.isAdminEmail(profile.email ?? email)
            ? _selectedRole
            : profile.role,
      );

      await _saveRememberedAccount();

      debugPrint(
        '=== LOGIN ROLE VERIFIED === '
        'role=${_profileSession.activeRole?.name ?? profile.role.name}',
      );

      debugPrint('=== LOGIN STEP 3: AGREEMENT START ===');

      await _showAgreementIfRequired();

      debugPrint('=== LOGIN STEP 3: AGREEMENT SUCCESS ===');

      if (!mounted) {
        return;
      }

      debugPrint('=== LOGIN STEP 4: AUTH COMPLETE — REFRESH AUTH BLOC ===');

      context.read<AuthBloc>().add(const AuthStarted());

      debugPrint('=== LOGIN STEP 4: AUTH BLOC REFRESH REQUESTED ===');
    } on AuthFailure catch (error) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'AUTH EXCEPTION: '
        'code=${error.code}, '
        'message=${error.message}',
      );

      String message;

      switch (error.code) {
        case 'user_invalid_credentials':
        case 'user_not_found':
          message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          break;

        case 'user_invalid_email':
          message = 'صيغة البريد الإلكتروني غير صحيحة.';
          break;

        case 'user_blocked':
          message = 'هذا الحساب معطّل حالياً.';
          break;

        case 'rate_limit_exceeded':
          message = 'تمت محاولات كثيرة. حاول مرة أخرى لاحقاً.';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بالخدمة.';
          break;

        default:
          message = 'تعذر تسجيل الدخول حالياً. حاول مرة أخرى.';
      }

      _showMessage(message);
    } catch (error, stackTrace) {
      debugPrint('=== LOGIN UNEXPECTED ERROR ===');
      debugPrint('ERROR TYPE: ${error.runtimeType}');
      debugPrint('ERROR: $error');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) {
        return;
      }

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
                              await _authRepository.sendPasswordRecovery(
                                email: email,
                                redirectUrl: Uri.base
                                    .resolve('reset-password')
                                    .toString(),
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
                            } on AuthFailure catch (error) {
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
                                case 'user_invalid_email':
                                  message = 'صيغة البريد الإلكتروني غير صحيحة.';
                                  break;

                                case 'user_not_found':
                                  message = 'لا يوجد حساب مرتبط بهذا البريد.';
                                  break;

                                case 'rate_limit_exceeded':
                                  message =
                                      'تم تجاوز عدد المحاولات. حاول لاحقاً.';
                                  break;

                                case 'network-request-failed':
                                  message = 'تعذر الاتصال بالخدمة.';
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LoginBackgroundPainter(
                primary: scheme.primary,
                secondary: scheme.secondary,
                surface: scheme.surface,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 600;

                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 18 : 42,
                    16,
                    compact ? 18 : 42,
                    40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 880),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          _buildBrandHeader(context),
                          const SizedBox(height: 30),
                          _buildRoleSelector(context),
                          const SizedBox(height: 0),
                          _buildLoginCard(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 118,
          child: CustomPaint(painter: TRLogoPainter(color: scheme.tertiary)),
        ),
        const SizedBox(height: 2),
        Text(
          'TRACÉ RAFFINÉ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
            letterSpacing: 3.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 190,
              height: 1,
              color: scheme.tertiary.withValues(alpha: 0.65),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Transform.rotate(
                angle: 0.785398,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.tertiary, width: 1.3),
                  ),
                ),
              ),
            ),
            Container(
              width: 190,
              height: 1,
              color: scheme.tertiary.withValues(alpha: 0.65),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'GLOBAL DIGITAL EMBROIDERY MARKETPLACE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.secondary,
            letterSpacing: 2.1,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(46, 48, 46, 36),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
        border: Border.all(
          color: scheme.tertiary.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 45,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInputField(
            context,
            controller: _emailController,
            label: 'البريد الإلكتروني',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 18),
          _buildPasswordField(context),
          const SizedBox(height: 14),
          _buildRememberRow(context),
          const SizedBox(height: 18),
          _buildPrimaryLoginButton(context),
          const SizedBox(height: 14),
          const SizedBox(height: 28),
          _buildTerms(context),
          const SizedBox(height: 18),
          _buildCreateAccountFooter(context),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      enabled: !_isLoading,
      style: TextStyle(
        fontFamily: 'Cairo',
        color: scheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textDirection: TextDirection.ltr,
      enabled: !_isLoading,
      onSubmitted: (_) {
        if (!_isLoading) {
          _submit();
        }
      },
      style: TextStyle(
        fontFamily: 'Cairo',
        color: scheme.onSurface,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: 'كلمة المرور',
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          size: 28,
          color: scheme.onSurfaceVariant,
        ),
        suffixIcon: IconButton(
          tooltip: _obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
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
            size: 28,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
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
          side: BorderSide(color: scheme.secondary, width: 1.2),
        ),
        Text(
          'تذكّرني',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: scheme.onSurface,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _isLoading ? null : _forgotPassword,
          child: Text(
            'نسيت كلمة المرور؟',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: scheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryLoginButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: scheme.secondary.withValues(alpha: 0.7)),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 23,
                height: 23,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildTerms(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 30, color: scheme.secondary),
        const SizedBox(width: 10),
        Text(
          'عند متابعة التسجيل، أنت توافق على ',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            _showMessage('صفحة شروط الاستخدام قيد الإعداد.');
          },
          child: Text(
            'شروط الاستخدام',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.secondary,
            ),
          ),
        ),
        Text(
          ' و',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        GestureDetector(
          onTap: () {
            _showMessage('صفحة سياسة الخصوصية قيد الإعداد.');
          },
          child: Text(
            'سياسة الخصوصية',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAccountFooter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'ليس لديك حساب؟',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: scheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RegisterScreen(role: _selectedRole),
                    ),
                  );
                },
          child: const Text('إنشاء حساب'),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.94),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.72)),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleItem(
              context,
              role: UserRole.customer,
              label: 'عميل',
              subtitle: 'تصفح وشراء التصاميم',
              icon: Icons.people_outline_rounded,
            ),
          ),
          Expanded(
            child: _buildRoleItem(
              context,
              role: UserRole.designer,
              label: 'مصمم',
              subtitle: 'عرض وبيع التصاميم',
              icon: Icons.draw_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleItem(
    BuildContext context, {
    required UserRole role,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedRole == role;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: 104,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primary, scheme.primaryContainer],
                )
              : null,
          color: selected ? null : scheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: role == UserRole.customer
                ? const Radius.circular(35)
                : Radius.zero,
            topRight: role == UserRole.designer
                ? const Radius.circular(35)
                : Radius.zero,
          ),
          border: Border.all(
            color: selected ? scheme.secondary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 27,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5,
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.78)
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




