import 'package:flutter/material.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_back_button.dart';
import 'package:trace_raffine/core/ui/maison_silk_sweep_button.dart';
import 'package:trace_raffine/core/responsive/app_breakpoints.dart';
import '../onboarding/services/agreement_service.dart';
import '../profile/services/profile_session_service.dart';
import 'domain/repositories/auth_repository.dart';
import '../../domain/entities/user_role.dart';
import 'package:trace_raffine/core/security/role_policy.dart';
import 'domain/exceptions/auth_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/auth_event.dart';
import 'services/remembered_login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onBackToStart});

  final VoidCallback? onBackToStart;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  AuthRepository get _authRepository => context.read<AuthRepository>();

  ProfileSessionService get _profileSession =>
      context.read<ProfileSessionService>();
  final AgreementService _agreementService = AgreementService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;

  bool _obscurePassword = true;
  bool _rememberAccount = false;
  bool _isLoading = false;
  bool _loginCompleted = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    );
    _loadRememberedAccount();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberedAccount() async {
    final remembered = await RememberedLoginService.load();

    if (!mounted || remembered == null) {
      return;
    }

    setState(() {
      _rememberAccount = true;
      _emailController.text = remembered.email;
      _selectedRole = remembered.role;
    });
  }

  Future<void> _saveRememberedAccount() {
    return RememberedLoginService.save(
      email: _emailController.text,
      role: _selectedRole,
      remember: _rememberAccount,
    );
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
        return _RoleAgreementDialog(
          role: _profileSession.activeRole ?? profile.role,
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('البريد الإلكتروني وكلمة المرور مطلوبة لتسجيل الدخول.');
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

      var profile = await _profileSession.loadCurrentProfile();

      if (profile == null) {
        debugPrint(
          '=== LOGIN PROFILE MISSING: ATTEMPTING SAFE PROFILE REPAIR === '
          'requestedRole=${_selectedRole.name}',
        );
        try {
          profile = await _profileSession.ensureCurrentProfile(
            role: _selectedRole,
          );
        } catch (error, stackTrace) {
          debugPrint('=== LOGIN PROFILE REPAIR FAILED === $error');
          debugPrintStack(stackTrace: stackTrace);
          try {
            await _authRepository.signOut();
          } catch (_) {}
          _profileSession.clear();
          _loginCompleted = false;
          throw AuthFailure(
            code: 'profile_creation_failed',
            message: 'الحساب موجود لكن تعذر تجهيز ملف الحساب. حاول مرة أخرى.',
          );
        }
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

        final actualLabel = profile.role == UserRole.designer ? 'مصمم' : 'عميل';

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
        case 'account_suspended':
          message = 'هذا الحساب موقوف حالياً من إدارة المنصة.';
          break;

        case 'email_already_exists':
          message = 'البريد الإلكتروني مستخدم مسبقاً في حساب آخر.';
          break;

        case 'phone_already_exists':
          message = 'رقم الهاتف مستخدم مسبقاً في حساب آخر.';
          break;

        case 'invalid_phone':
          message = 'رقم الهاتف غير صحيح. تأكد من رمز الدولة والرقم.';
          break;

        case 'weak_password':
          message = 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل.';
          break;

        case 'profile_not_found':
        case 'profile_creation_failed':
          message = error.message;
          break;

        case 'rate_limit_exceeded':
          message = 'تمت محاولات كثيرة. حاول مرة أخرى لاحقاً.';
          break;

        case 'network-request-failed':
          message = 'تعذر الاتصال بالخدمة.';
          break;

        default:
          message = message =
              "تعذر تسجيل الدخول حالياً. حاول مرة أخرى. [${error.code}]";
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

      _showMessage('تعذر إكمال تسجيل الدخول حالياً. حاول مرة أخرى.');
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
                  EditorialButton(
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
                                redirectUrl:
                                    'https://trace-raffine.app/reset-password',
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
                    loading: loading,
                    label: 'إرسال الرابط',
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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = context.isCompact;
    final expandedScene = context.isExpanded || context.isLarge;

    return Scaffold(
      backgroundColor: AppTheme.obsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (expandedScene)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: size.width * 0.56,
              child: ClipRect(
                child: Image.asset(
                  'assets/images/LOG IN.jpg',
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.08, 0.0),
                  filterQuality: FilterQuality.high,
                ),
              ),
            )
          else
            Positioned.fill(
              child: Image.asset(
                'assets/images/LOG IN.jpg',
                fit: BoxFit.cover,
                alignment: const Alignment(0.0, 0.0),
                filterQuality: FilterQuality.high,
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: expandedScene
                        ? [
                            AppTheme.obsidian.withValues(alpha: 0.78),
                            AppTheme.burgundyBlack.withValues(alpha: 0.52),
                            AppTheme.deepBurgundy.withValues(alpha: 0.18),
                            Colors.transparent,
                          ]
                        : [
                            AppTheme.obsidian.withValues(alpha: 0.30),
                            AppTheme.deepBurgundy.withValues(alpha: 0.22),
                            AppTheme.obsidian.withValues(alpha: 0.40),
                          ],
                    stops: expandedScene
                        ? const [0.0, 0.36, 0.62, 1.0]
                        : const [0.0, 0.52, 1.0],
                  ),
                ),
              ),
            ),
          ),

          if (!expandedScene)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.obsidian.withValues(alpha: 0.05),
                        AppTheme.deepBurgundy.withValues(alpha: 0.30),
                      ],
                      stops: const [0.0, 0.58, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CoutureBeadsPainter(
                  denseSide: expandedScene ? 1.0 : 0.68,
                ),
              ),
            ),
          ),

          Align(
            alignment: expandedScene
                ? Alignment.centerLeft
                : Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                compact ? 20 : 48,
                compact ? 22 : 48,
                compact ? 20 : 48,
                compact ? 34 : 64,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: expandedScene ? 500 : 560,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: compact ? 6 : 18),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceController,
                        curve: const Interval(
                          0.18,
                          0.58,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.08, 0.0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _entranceController,
                                curve: const Interval(
                                  0.18,
                                  0.58,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                        child: Text(
                          'تسجيل الدخول',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: compact ? 42 : 58,
                            fontWeight: FontWeight.w700,
                            height: 0.98,
                            letterSpacing: -1.2,
                            color: AppTheme.warmIvory,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? 30 : 42),
                    SizedBox(height: compact ? 26 : 34),
                    _buildRoleSelector(context),
                    SizedBox(height: compact ? 10 : 14),
                    _buildLoginForm(context),
                  ],
                ),
              ),
            ),
          ),

          PositionedDirectional(
            top: 18,
            start: 20,
            child: MaisonBackButton(
              onPressed: () {
                widget.onBackToStart?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final compact = context.isCompact;

    final formCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.56, 0.94, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: formCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0.0),
          end: Offset.zero,
        ).animate(formCurve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              context,
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildPasswordField(context),
            SizedBox(height: compact ? 10 : 12),
            _buildRememberRow(context),
            SizedBox(height: compact ? 20 : 24),
            _buildPrimaryLoginButton(context),
          ],
        ),
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      enabled: !_isLoading,
      style: const TextStyle(
        fontFamily: 'Cairo',
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: AppTheme.mutedIvory.withValues(alpha: 0.82),
        ),
        prefixIcon: Icon(
          icon,
          size: 22,
          color: AppTheme.softRose.withValues(alpha: 0.68),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
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
      style: const TextStyle(
        fontFamily: 'Cairo',
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
        ),
        labelText: 'كلمة المرور',
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: AppTheme.mutedIvory.withValues(alpha: 0.82),
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          size: 22,
          color: AppTheme.softRose.withValues(alpha: 0.68),
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
            size: 22,
            color: AppTheme.softRose.withValues(alpha: 0.68),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberRow(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: _rememberAccount,
          onChanged: _isLoading
              ? null
              : (value) {
                  final remember = value ?? false;
                  setState(() {
                    _rememberAccount = remember;
                  });
                  if (!remember) {
                    RememberedLoginService.clear();
                  }
                },
          side: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 1.2,
          ),
          activeColor: AppTheme.richBurgundy,
        ),
        Text(
          'تذكّرني',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: AppTheme.warmIvory.withValues(alpha: 0.88),
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
              color: AppTheme.softRose.withValues(alpha: 0.82),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryLoginButton(BuildContext context) {
    final buttonCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.78, 1.0, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: buttonCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.015, 0.0),
          end: Offset.zero,
        ).animate(buttonCurve),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: MaisonSilkSweepButton(
            label: 'تسجيل الدخول',
            isLoading: _isLoading,
            onTap: _isLoading ? null : _submit,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(BuildContext context) {
    final roleCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.42, 0.78, curve: Curves.easeOutCubic),
    );

    return FadeTransition(
      opacity: roleCurve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.035, 0.0),
          end: Offset.zero,
        ).animate(roleCurve),
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
    final selected = _selectedRole == role;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectRole(role),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                height: 1.15,
                color: selected
                    ? AppTheme.warmIvory
                    : AppTheme.mutedIvory.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5,
                height: 1.25,
                color: selected
                    ? AppTheme.mutedIvory.withValues(alpha: 0.76)
                    : AppTheme.mutedIvory.withValues(alpha: 0.38),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: selected ? 54 : 18,
                height: 1,
                color: selected
                    ? AppTheme.softRose
                    : AppTheme.divider.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SilkSweepButton extends StatefulWidget {
  const _SilkSweepButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<_SilkSweepButton> createState() => _SilkSweepButtonState();
}

class _SilkSweepButtonState extends State<_SilkSweepButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (mounted) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _hovered = false);
        }
      },
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Stack(
              alignment: AlignmentDirectional.centerStart,
              children: [
                AnimatedContainer(
                  duration: MaisonMotion.silkSweep,
                  curve: Curves.easeOutCubic,
                  height: 30,
                  width: _hovered ? 220 : 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        AppTheme.richBurgundy.withValues(alpha: 0.12),
                        AppTheme.primaryBurgundy.withValues(alpha: 0.26),
                        AppTheme.richBurgundy.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.24, 0.5, 0.76, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, end: 12),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppTheme.warmIvory.withValues(
                        alpha: _hovered ? 1.0 : 0.88,
                      ),
                    ),
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.label,
                            textDirection: TextDirection.rtl,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoutureBeadsPainter extends CustomPainter {
  const _CoutureBeadsPainter({required this.denseSide});

  final double denseSide;

  @override
  void paint(Canvas canvas, Size size) {
    final beads = <({double x, double y, double r, double a})>[
      (x: 0.80, y: 0.16, r: 2.0, a: 0.22),
      (x: 0.88, y: 0.23, r: 3.0, a: 0.30),
      (x: 0.73, y: 0.31, r: 1.6, a: 0.18),
      (x: 0.92, y: 0.38, r: 2.4, a: 0.26),
      (x: 0.81, y: 0.47, r: 3.6, a: 0.34),
      (x: 0.69, y: 0.55, r: 1.8, a: 0.18),
      (x: 0.87, y: 0.62, r: 2.6, a: 0.28),
      (x: 0.76, y: 0.70, r: 1.5, a: 0.16),
      (x: 0.94, y: 0.77, r: 2.8, a: 0.24),
      (x: 0.65, y: 0.84, r: 1.8, a: 0.15),
    ];

    final glow = Paint()..style = PaintingStyle.fill;
    final bead = Paint()..style = PaintingStyle.fill;

    for (final item in beads) {
      final center = Offset(size.width * item.x, size.height * item.y);
      final radius = item.r * (size.shortestSide / 520.0).clamp(0.78, 1.16);
      final alpha = item.a * denseSide;

      glow.color = AppTheme.roseBurgundy.withValues(alpha: alpha * 0.20);
      canvas.drawCircle(center, radius * 2.4, glow);

      bead.shader = RadialGradient(
        colors: [
          AppTheme.warmIvory.withValues(alpha: alpha * 0.78),
          AppTheme.softRose.withValues(alpha: alpha),
          AppTheme.primaryBurgundy.withValues(alpha: alpha * 0.92),
        ],
        stops: const [0.0, 0.38, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.8));

      canvas.drawCircle(center, radius, bead);
      bead.shader = null;
    }
  }

  @override
  bool shouldRepaint(covariant _CoutureBeadsPainter oldDelegate) {
    return oldDelegate.denseSide != denseSide;
  }
}

class _RoleAgreementDialog extends StatelessWidget {
  const _RoleAgreementDialog({required this.role, required this.onAccepted});

  final UserRole role;
  final VoidCallback onAccepted;

  String get _title {
    switch (role) {
      case UserRole.customer:
        return 'أهلاً بك في عالم TRACÉ RAFFINÉ';
      case UserRole.designer:
        return 'اتفاقية انضمام المصممين | TRACÉ RAFFINÉ';
    }
  }

  String get _introduction {
    switch (role) {
      case UserRole.customer:
        return 'عزيزنا العميل، مرحباً بك في «المسار الراقي». '
            'يسعدنا انضمامك إلى مجتمع يجمع بين أصالة التطريز '
            'وأعلى مستويات الفخامة الرقمية. نعدك بتجربة استثنائية '
            'واقتناء تصاميم صُممت بكل دقة لتلبي تطلعاتك.';
      case UserRole.designer:
        return 'أهلاً بك كشريك إبداعي في «المسار الراقي». '
            'لنضمن الحفاظ على اسم المنصة وتقديم أعلى معايير الجودة '
            'لعملائنا، يُرجى الاطلاع والموافقة على الشروط والأحكام '
            'التالية قبل البدء بنشر تصاميمك.';
    }
  }

  List<Widget> get _sections {
    switch (role) {
      case UserRole.customer:
        return const [
          _AgreementSection(
            number: '1',
            title: 'نظام الحماية والأمان',
            body:
                'تخضع المحتويات الرقمية لوسائل حماية تقنية مناسبة '
                'لمنع الاستخدام غير المصرح به أو إعادة توزيع الملفات. '
                'قد تؤدي محاولات التحايل على أنظمة الحماية إلى تقييد '
                'الوصول إلى الحساب وفق سياسات المنصة.',
          ),
          _AgreementSection(
            number: '2',
            title: 'سياسة المنتجات الرقمية',
            body:
                'جميع التصاميم والملفات المتاحة على المنصة هي منتجات '
                'رقمية. وبمجرد إتمام عملية الشراء وتسليم المحتوى الرقمي، '
                'تُعامل العملية وفق سياسة المنتجات الرقمية المعتمدة '
                'على المنصة، مع مراعاة الحالات التي يفرض فيها القانون '
                'المعمول به خلاف ذلك.',
          ),
        ];

      case UserRole.designer:
        return const [
          _AgreementSection(
            number: '1',
            title: 'بوابة الجودة الصارمة',
            body:
                'تخضع جميع الملفات المرفوعة للمراجعة الفنية والبرمجية '
                'قبل النشر. يجب أن تكون الملفات خالية من الأخطاء '
                'الميكانيكية ومهيأة وفق معايير الرقمنة المعتمدة. '
                'أي ملف لا يستوفي المعايير قد يتم رفضه مع توضيح '
                'الأسباب التقنية اللازمة للتعديل.',
          ),
          _AgreementSection(
            number: '2',
            title: 'الأرباح والعمولات',
            body:
                'تقتطع المنصة نسبة 20% من قيمة كل عملية بيع للتصميم، '
                'ويحصل المصمم على 80% وفق آلية التسوية والسحب '
                'المعتمدة في لوحة التحكم.',
          ),
          _AgreementSection(
            number: '3',
            title: 'الملكية الفكرية',
            body:
                'يتعهد المصمم بامتلاكه الحقوق اللازمة للرقمنة والتصميم '
                'المرفوع، ويتحمل مسؤولية أي انتهاك لحقوق الملكية الفكرية '
                'أو حقوق الغير ناتج عن المحتوى الذي يقوم برفعه.',
          ),
        ];
    }
  }

  String get _buttonText {
    switch (role) {
      case UserRole.customer:
        return 'أوافق وأبدأ التصفح';
      case UserRole.designer:
        return 'أوافق وألتزم بالشروط والمعايير';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.burgundyBlack,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.35),
              ),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 40,
                  spreadRadius: 4,
                  offset: Offset(0, 18),
                  color: Colors.black54,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            _introduction,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              color: AppTheme.mutedIvory,
                              height: 1.9,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ..._sections,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.obsidian.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'بالضغط على زر الموافقة، فأنت تقر باطلاعك على '
                      'السياسات والشروط الخاصة بدورك داخل المنصة '
                      'وموافقتك عليها.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        color: AppTheme.mutedText,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: EditorialButton(
                      onPressed: onAccepted,
                      label: _buttonText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'TRACÉ RAFFINÉ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppTheme.warmIvory,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(width: 58, height: 1, color: AppTheme.softRose),
        const SizedBox(height: 16),
        Text(
          _title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppTheme.warmIvory,
          ),
        ),
      ],
    );
  }
}

class _AgreementSection extends StatelessWidget {
  const _AgreementSection({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.obsidian.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.55),
              ),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.softRose,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    color: AppTheme.mutedText,
                    height: 1.75,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
