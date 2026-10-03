import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

import 'package:trace_raffine/core/motion/maison_motion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/core/ui/editorial_button.dart';
import 'package:trace_raffine/core/ui/maison_back_button.dart';
import 'package:trace_raffine/domain/entities/user_role.dart';
import 'package:trace_raffine/features/auth/domain/repositories/auth_repository.dart';
import 'package:trace_raffine/features/onboarding/services/agreement_service.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  final _firstNameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Country? _selectedCountry;
  final _confirmController = TextEditingController();

  final AgreementService _agreementService = AgreementService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: MaisonMotion.pageEntrance,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _fatherNameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final firstName = _firstNameController.text.trim();
    final fatherName = _fatherNameController.text.trim();
    final surname = _surnameController.text.trim();
    final name = [
      firstName,
      fatherName,
      surname,
    ].where((part) => part.isNotEmpty).join(' ');
    final email = _emailController.text.trim();
    final phone = _phoneController.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (firstName.isEmpty ||
        fatherName.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      _message('أكمل جميع الحقول.');
      return;
    }

    final country = _selectedCountry;
    if (country == null) {
      _message('اختر الدولة أولاً.');
      return;
    }

    if (phone.length < 5) {
      _message('أدخل رقم هاتف صحيح.');
      return;
    }

    if (password != confirm) {
      _message('كلمتا المرور غير متطابقتين.');
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        email: email,
        password: password,
        name: name,
        phone: '+${country.phoneCode}$phone',
        role: widget.role,
      ),
    );
  }

  Future<void> _handleRegistrationAuthenticated() async {
    if (!mounted) return;

    final user = context.read<AuthRepository>().currentUser;

    if (user == null) {
      _message('تعذر الوصول إلى الحساب بعد إنشاء الحساب.');
      return;
    }

    final role = widget.role;
    final roleName = role.name;

    final accepted = await _agreementService.hasAccepted(
      uid: user.id,
      role: roleName,
    );

    if (!mounted) return;

    if (accepted) {
      Navigator.of(context).pop();
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return _RoleAgreementDialog(
          role: role,
          onAccepted: () async {
            await _agreementService.markAccepted(uid: user.id, role: roleName);

            if (!mounted) return;

            Navigator.of(context).pop();
          },
        );
      },
    );

    if (!mounted) return;

    Navigator.of(context).pop();
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
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 560;
    final expandedScene = size.width >= 900;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _handleRegistrationAuthenticated();
        }

        if (state.status == AuthStatus.failure) {
          _message(state.failure?.message ?? 'تعذر إنشاء الحساب.');
        }
      },
      child: Scaffold(
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
                              AppTheme.obsidian.withValues(alpha: 0.82),
                              AppTheme.burgundyBlack.withValues(alpha: 0.56),
                              AppTheme.deepBurgundy.withValues(alpha: 0.16),
                              Colors.transparent,
                            ]
                          : [
                              AppTheme.obsidian.withValues(alpha: 0.34),
                              AppTheme.deepBurgundy.withValues(alpha: 0.20),
                              AppTheme.obsidian.withValues(alpha: 0.46),
                            ],
                      stops: expandedScene
                          ? const [0.0, 0.34, 0.62, 1.0]
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
                          AppTheme.obsidian.withValues(alpha: 0.04),
                          AppTheme.deepBurgundy.withValues(alpha: 0.34),
                        ],
                        stops: const [0.0, 0.60, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: const _CoutureBeadsPainter(denseSide: 0.88),
                ),
              ),
            ),
            PositionedDirectional(
              top: 18,
              start: 20,
              child: MaisonBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Align(
              alignment: expandedScene
                  ? Alignment.centerLeft
                  : Alignment.bottomCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 48,
                  compact ? 78 : 48,
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
                      _entrance(
                        interval: const Interval(
                          0.14,
                          0.52,
                          curve: MaisonMotion.easeOut,
                        ),
                        begin: const Offset(0.055, 0.0),
                        child: const Text(
                          'TRACÉ RAFFINÉ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontEditorial,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 4.0,
                            color: AppTheme.softRose,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 9 : 12),
                      _entrance(
                        interval: const Interval(
                          0.20,
                          0.60,
                          curve: MaisonMotion.easeOut,
                        ),
                        begin: const Offset(0.075, 0.0),
                        child: Text(
                          'إنشاء حساب',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: AppTheme.fontArabic,
                            fontSize: compact ? 42 : 58,
                            fontWeight: FontWeight.w700,
                            height: 0.98,
                            letterSpacing: -1.2,
                            color: AppTheme.warmIvory,
                          ),
                        ),
                      ),
                      SizedBox(height: compact ? 25 : 32),
                      _buildRoleIdentity(compact),
                      SizedBox(height: compact ? 22 : 28),
                      _buildForm(compact),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleIdentity(bool compact) {
    final label = widget.role == UserRole.designer ? 'مصمم' : 'عميل';
    final subtitle = widget.role == UserRole.designer
        ? 'عرض وبيع التصاميم'
        : 'تصفح وشراء التصاميم';

    final curve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.40, 0.70, curve: MaisonMotion.easeOut),
    );

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.028, 0.0),
          end: Offset.zero,
        ).animate(curve),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: compact ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.warmIvory,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontArabic,
                fontSize: 11,
                letterSpacing: 0.15,
                color: AppTheme.mutedIvory.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: 11),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 54,
                height: 1,
                color: AppTheme.softRose.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool compact) {
    final formCurve = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.54, 0.94, curve: MaisonMotion.easeOut),
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
              controller: _firstNameController,
              label: 'الاسم الأول',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildInputField(
              controller: _fatherNameController,
              label: 'اسم الأب',
              icon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildInputField(
              controller: _surnameController,
              label: 'اللقب',
              icon: Icons.badge_outlined,
              textInputAction: TextInputAction.next,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildInputField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildPhoneField(),
            SizedBox(height: compact ? 20 : 24),
            _buildPasswordField(
              controller: _passwordController,
              label: 'كلمة المرور',
              obscureText: _obscurePassword,
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            SizedBox(height: compact ? 20 : 24),
            _buildPasswordField(
              controller: _confirmController,
              label: 'تأكيد كلمة المرور',
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              onSubmitted: (_) => _submit(),
            ),
            SizedBox(height: compact ? 24 : 28),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final loading = state.status == AuthStatus.loading;

                return _RegisterSilkButton(
                  label: 'إنشاء الحساب',
                  loading: loading,
                  onPressed: loading ? null : _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: textDirection,
      style: const TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      cursorColor: AppTheme.softRose,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
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
      ),
    );
  }

  Widget _buildPhoneField() {
    final country = _selectedCountry;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontFamily: AppTheme.fontArabic,
              color: AppTheme.warmIvory,
              fontSize: 16,
            ),
            cursorColor: AppTheme.softRose,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: 'أدخل الرقم المحلي بدون رمز الدولة',
              hintStyle: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.mutedIvory.withValues(alpha: 0.48),
                fontSize: 12,
              ),
              labelStyle: TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.mutedIvory.withValues(alpha: 0.82),
              ),
              floatingLabelStyle: const TextStyle(
                fontFamily: AppTheme.fontArabic,
                color: AppTheme.softRose,
              ),
              prefixIcon: Icon(
                Icons.phone_outlined,
                size: 22,
                color: AppTheme.softRose.withValues(alpha: 0.68),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.divider.withValues(alpha: 0.72),
                  width: 0.8,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppTheme.divider.withValues(alpha: 0.72),
                  width: 0.8,
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.softRose, width: 1.1),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              showSearch: true,
              useSafeArea: true,
              countryListTheme: CountryListThemeData(
                backgroundColor: AppTheme.burgundyBlack,
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.warmIvory,
                  fontSize: 15,
                ),
                searchTextStyle: const TextStyle(
                  fontFamily: AppTheme.fontArabic,
                  color: AppTheme.warmIvory,
                ),
                inputDecoration: InputDecoration(
                  labelText: 'البحث عن دولة',
                  labelStyle: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.mutedIvory,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.softRose,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.divider),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.softRose),
                  ),
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
                bottomSheetHeight: 620,
              ),
              onSelect: (selected) {
                setState(() => _selectedCountry = selected);
              },
            );
          },
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.divider, width: 0.8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  country?.flagEmoji ?? '🌍',
                  style: const TextStyle(fontSize: 21),
                ),
                const SizedBox(width: 7),
                Text(
                  country == null ? '+ رمز' : '+${country.phoneCode}',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    color: AppTheme.warmIvory,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppTheme.softRose,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textDirection: TextDirection.ltr,
      onSubmitted: onSubmitted,
      style: const TextStyle(
        fontFamily: AppTheme.fontArabic,
        color: AppTheme.warmIvory,
        fontSize: 16,
      ),
      cursorColor: AppTheme.softRose,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppTheme.divider.withValues(alpha: 0.72),
            width: 0.8,
          ),
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
          Icons.lock_outline_rounded,
          size: 22,
          color: AppTheme.softRose.withValues(alpha: 0.68),
        ),
        suffixIcon: IconButton(
          tooltip: obscureText ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 22,
            color: AppTheme.softRose.withValues(alpha: 0.68),
          ),
        ),
      ),
    );
  }

  Widget _entrance({
    required Interval interval,
    required Offset begin,
    required Widget child,
  }) {
    final curve = CurvedAnimation(parent: _entranceController, curve: interval);

    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }
}

class _RegisterSilkButton extends StatefulWidget {
  const _RegisterSilkButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  State<_RegisterSilkButton> createState() => _RegisterSilkButtonState();
}

class _RegisterSilkButtonState extends State<_RegisterSilkButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _disabled => widget.loading || widget.onPressed == null;

  @override
  Widget build(BuildContext context) {
    final active = _hovered && !_disabled;

    return MouseRegion(
      cursor: _disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        if (!_disabled) {
          setState(() => _hovered = true);
        }
      },
      onExit: (_) {
        if (_hovered) {
          setState(() => _hovered = false);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _disabled
            ? null
            : (_) {
                setState(() => _pressed = true);
              },
        onTapUp: _disabled
            ? null
            : (_) {
                setState(() => _pressed = false);
              },
        onTapCancel: _disabled
            ? null
            : () {
                setState(() => _pressed = false);
              },
        onTap: _disabled ? null : widget.onPressed,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: MaisonMotion.silkSweep,
                curve: MaisonMotion.easeOut,
                width: active ? 250 : 0,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      AppTheme.richBurgundy.withValues(alpha: 0.14),
                      AppTheme.roseBurgundy.withValues(alpha: 0.30),
                      AppTheme.richBurgundy.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.24, 0.50, 0.76, 1.0],
                  ),
                ),
              ),
              AnimatedScale(
                scale: _pressed ? 0.985 : 1.0,
                duration: MaisonMotion.editorialInteraction,
                curve: MaisonMotion.easeOut,
                child: AnimatedDefaultTextStyle(
                  duration: MaisonMotion.editorialInteraction,
                  curve: MaisonMotion.easeOut,
                  style: TextStyle(
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 18,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                    color: _disabled ? AppTheme.mutedText : AppTheme.warmIvory,
                  ),
                  child: widget.loading
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.7,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.warmIvory,
                            ),
                          ),
                        )
                      : Text(widget.label, textDirection: TextDirection.rtl),
                ),
              ),
            ],
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.softRose.withValues(alpha: 0.30),
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
                              fontFamily: AppTheme.fontArabic,
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
                      border: Border.all(
                        color: AppTheme.divider.withValues(alpha: 0.65),
                      ),
                    ),
                    child: const Text(
                      'بالضغط على زر الموافقة، فأنت تقر باطلاعك على '
                      'السياسات والشروط الخاصة بدورك داخل المنصة '
                      'وموافقتك عليها.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppTheme.fontArabic,
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
            fontFamily: AppTheme.fontEditorial,
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
            fontFamily: AppTheme.fontArabic,
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
                fontFamily: AppTheme.fontEditorial,
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
                    fontFamily: AppTheme.fontArabic,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.warmIvory,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontArabic,
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
