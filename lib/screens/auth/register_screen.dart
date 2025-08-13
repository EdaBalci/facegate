import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facegate/blocs/auth/auth_bloc.dart';
import 'package:facegate/blocs/auth/auth_event.dart';
import 'package:facegate/blocs/auth/auth_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Tek noktadan kullanılacak Lottie loader helper'ı
  Widget _lottieLoader({double size = 50}) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        'assets/animations/loader.json',
        repeat: true,
        animate: true,
        fit: BoxFit.contain,
      ),
    );
  }

  void _onRegisterPressed() {
    // AuthRegisterRequested event’i AuthBloc'a gönderilir (Firebase kaydı başlatır)
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Kayıt Ol" / "Register"
        title: Text(LocaleKeys.auth_register_title.tr()),
        actions: [translate(context)],
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthWaitingApproval) {
            context.go('/waiting');
          } else if (state is AuthFailure) {
            // Backend mesajını göster (i18n dışı gelebilir)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.auth_email.tr(),
                    ),
                    validator: (value) => (value != null && value.contains('@'))
                        ? null
                        : LocaleKeys.auth_email_invalid.tr(),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.auth_password.tr(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        (value != null && value.length >= 6)
                            ? null
                            : LocaleKeys.auth_password_min_chars.tr(),
                  ),

                  const SizedBox(height: 24),

                  // Register button / spinner
                  isLoading
                      ? _lottieLoader(size: 50)
                      : ElevatedButton(
                          onPressed: _onRegisterPressed,
                          child: Text(LocaleKeys.auth_register_button.tr()),
                        ),

                  const SizedBox(height: 12),

                  // Back to Login link
                  TextButton(
                    onPressed: () => context.pop(), // önceki sayfaya dön
                    child: Text(LocaleKeys.auth_login_link.tr()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
