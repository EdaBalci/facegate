import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';



////Eğer kullanıcı AuthBloc üzerinden AuthSuccess("personnel") durumu ile giriş yaptıysa
//GoRouter bu sayfaya yönlendirir


class PersonnelHomeScreen extends StatelessWidget {
  const PersonnelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Paneli'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOutUser(context),
          ),
        ],
      ),
      
    );
  }
}
