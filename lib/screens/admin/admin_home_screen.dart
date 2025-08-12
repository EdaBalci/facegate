import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// i18n
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

// Eğer kullanıcı AuthBloc üzerinden AuthSuccess("admin") durumu ile giriş yaptıysa
// GoRouter bu sayfaya yönlendirir

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Başlık i18n
        title: Text(LocaleKeys.admin_panel_title.tr()),
        actions: [
          // Dil değiştirme: tr <-> en
          IconButton(
            tooltip: 'Change Language',
            icon: const Icon(Icons.language),
            onPressed: () async {
              final isTR = context.locale.languageCode == 'tr';
              await context.setLocale(Locale(isTR ? 'en' : 'tr'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOutUser(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // butonları sola hizalamak için
          children: [
            const SizedBox(height: 24),

            // Kayıt listesi
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/logs'),
              icon: const Icon(Icons.list),
              label: Text(LocaleKeys.logs_title.tr()),
            ),

            const SizedBox(height: 16),

            // Onay bekleyenler
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/approval'),
              icon: const Icon(Icons.pending_actions),
              label: Text(LocaleKeys.personnel_pending.tr()),
            ),

            const SizedBox(height: 16),

            // Rol atama
            ElevatedButton.icon(
              onPressed: () => context.go('/admin/assign-roles'),
              icon: const Icon(Icons.assignment_ind),
              label: Text(LocaleKeys.admin_roles_assign_role.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
