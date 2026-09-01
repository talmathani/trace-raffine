import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trace_raffine/core/theme/app_theme.dart';
import 'package:trace_raffine/domain/entities/user_role.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _message('أكمل جميع الحقول.');
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
        role: widget.role,
      ),
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value, style: const TextStyle(fontFamily: 'Cairo')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.of(context).pop();
        }

        if (state.status == AuthStatus.failure) {
          _message(state.failure?.message ?? 'تعذر إنشاء الحساب.');
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.obsidian,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'إنشاء حساب',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'انضم إلى TRACÉ RAFFINÉ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warmIvory,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _field(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _confirmController,
                    label: 'تأكيد كلمة المرور',
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final loading = state.status == AuthStatus.loading;

                        return ElevatedButton(
                          onPressed: loading ? null : _submit,
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'إنشاء الحساب',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        );
                      },
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Cairo'),
      ),
    );
  }
}
