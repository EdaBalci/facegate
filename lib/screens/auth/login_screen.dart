import 'package:facegate/widgets/custom_text_form_field.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // validate kontrolü yapar
  final _emailController = TextEditingController(); // input değeri okumak için
  final _passwordController = TextEditingController();

  Widget _lottieLoader({double size = 40}) {
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

  // form geçerliyse AuthLoginRequested eventi AuthBloc'a gönderilir
  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  // memory leak oluşmaması için sayfa kapatılırken temizlik
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
        // "Giriş Yap" / "Sign In"
        title: Text(LocaleKeys.auth_login_title.tr()),
        actions: [translate(context,)],
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        // AuthState değiştiğinde çalışır
        listener: (context, state) {
          if (state is AuthSuccess) {
            if (state.role == 'admin') {
              context.go('/admin/home');
            } else {
              context.go('/personnel/home');
            }
          } else if (state is AuthWaitingApproval) {
            context.go('/waiting');
          } else if (state is AuthFailure) {
            // Backend'ten gelen mesajı gösteriyoruz (i18n değilse bile)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        // AuthState değiştikçe UI'ı tekrar oluşturur
        builder: (context, state) {
          final isLoading = state is AuthLoading; // loading sırasında buton yerine spinner

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email
                  CustomTextFormField(
                    textEditingController: _emailController,
                    labelText: LocaleKeys.auth_email.tr(),
                    validator: (value) => (value != null && value.contains('@'))
                        ? null
                        : LocaleKeys.auth_email_invalid.tr(),
                  ),
                  const SizedBox(height: 16),

                  // Password
                  CustomTextFormField(
                    textEditingController: _passwordController,
                    labelText: LocaleKeys.auth_password.tr(),
                    obscureText: true,
                    validator: (value) => (value != null && value.length >= 6)
                        ? null
                        : LocaleKeys.auth_password_min_chars.tr(),
                  ),

                  const SizedBox(height: 24),

                  // Login button / spinner
                  isLoading
                      ? _lottieLoader(size: 50)
                      : ElevatedButton(
                          onPressed: _onLoginPressed,
                          child: Text(LocaleKeys.auth_login_button.tr()),
                        ),

                  const SizedBox(height: 12),

                  // Register link
                  TextButton(
                    onPressed: () => context.push('/register'),
                    child: Text(LocaleKeys.auth_register_link.tr()),
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
