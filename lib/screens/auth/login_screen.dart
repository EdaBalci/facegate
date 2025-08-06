import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:facegate/blocs/auth/auth_bloc.dart';
import 'package:facegate/blocs/auth/auth_event.dart';
import 'package:facegate/blocs/auth/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); //validate kontrolü yapar
  final _emailController = TextEditingController(); //input değeri okumak için
  final _passwordController = TextEditingController();


//form geçerliyse AuthLoginRequested eventi AuthBloc'a gönderilir
  void _onLoginPressed() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
  }

//memory leak oluşmaması için sayfa kapatılırken temizlik
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
        title: const Text('Giriş Yap'),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) { //AuthState değiştiğince çalışıyor
      if (state is AuthSuccess) {
      if (state.role == 'admin') {
      context.go('/admin/home');
      } else {
      context.go('/personnel/home');
     }
     } else if (state is AuthWaitingApproval) {
     context.go('/waiting');
     } else if (state is AuthFailure) {
     ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(state.message)),
    );
  }
},

        builder: (context, state) { //AuthState değiştirdikçe UI'ı tekrar oluşturur
          final isLoading = state is AuthLoading; //state AuthLoading ise buton yerine loading spinner gösterilecek

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField( //kullanıcıdan email şifre alır
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value != null && value.contains('@') //email geçerli mi kontrolü
                        ? null
                        : 'Geçerli bir email girin',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true, //şifreyi gizlemek için
                    validator: (value) =>
                        value != null && value.length >= 6
                            ? null
                            : 'En az 6 karakter girin',
                  ),
                  const SizedBox(height: 24),
                  isLoading // AuthLoading state aktif değilse 
                  //buton aktif olur ve onPressed ile _onLoginPressed() çalışır
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _onLoginPressed,
                          child: const Text('Giriş Yap'),
                        ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.push('/register'); //kayıt ol'a bastığında register sayfasına gider
                      //push sayesinde geri gelmesi mümkün
                    },
                    child: const Text('Hesabın yok mu? Kayıt ol'),
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


