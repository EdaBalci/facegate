
import 'package:facegate/utils/constants.dart';
import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//Eğer kullanıcı AuthBloc üzerinden AuthSuccess("admin") durumu ile giriş yaptıysa
//GoRouter bu sayfaya yönlendirir

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ProjectConstants.adminPanel),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOutUser(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //butonları sola hizalamak için
          children: [
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/admin/logs');
              },
              icon: const Icon(Icons.list),
              label: const Text('Giriş / Çıkış Kayıtları'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.go('/admin/approval');
              },
              icon: const Icon(Icons.pending_actions),
              label: const Text('Onay Bekleyen Personeller'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
            icon: const Icon(Icons.assignment_ind),
            label: const Text('Görev Atama'),
              onPressed: () => context.go('/admin/assign-roles'),
),

          ],
        ),
      ),
    );
  }
}
