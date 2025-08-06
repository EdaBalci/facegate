import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facegate/blocs/auth/auth_bloc.dart';
import 'package:facegate/blocs/auth/auth_event.dart';
import 'package:facegate/blocs/auth/auth_state.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onRegisterPressed() {
    //AuthRegisterRequested event’i AuthBloc'a gönderilir
    //Bu event sayesinde firebasde kayıt başlar
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
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
        title: const Text('Kayıt Ol'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthWaitingApproval) {
            context.go('/waiting');
          } else if (state is AuthFailure) {
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
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Geçerli bir email girin',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    validator: (value) =>
                        value != null && value.length >= 6
                            ? null
                            : 'En az 6 karakter girin',
                  ),
                  const SizedBox(height: 24),
                  isLoading //State AuthLoading ise spinner gösteriliyor değilse kayıt işlemi yapılıyor
                      ? const CircularProgressIndicator(): //True ise
                       ElevatedButton( //false ise
                          onPressed: _onRegisterPressed,
                          child: const Text('Kayıt Ol'),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.pop();
                      //Pop sayesinde önceki sayfaya döner
                    },
                    child: const Text('Zaten hesabın var mı? Giriş yap'),
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