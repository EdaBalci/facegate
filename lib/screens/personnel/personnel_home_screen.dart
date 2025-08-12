import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:facegate/repositories/log_repository.dart';
import 'package:facegate/widgets/language_switcher.dart';

// i18n
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

/// Eğer kullanıcı AuthBloc üzerinden AuthSuccess("personnel") durumu ile giriş yaptıysa
class PersonnelHomeScreen extends StatefulWidget {
  const PersonnelHomeScreen({super.key});

  @override
  State<PersonnelHomeScreen> createState() => _PersonnelHomeScreenState();
}

class _PersonnelHomeScreenState extends State<PersonnelHomeScreen> {
  final LogRepository _logRepository = LogRepository(); // firestore'a log yazmak için

  @override
  void initState() {
    super.initState();
    _logEntry(); // giriş logunu firestore'a yaz
  }

  Future<void> _logEntry() async {
    await _logRepository.logAction("entry"); // giriş yapan kullanıcıyı logs koleksiyonuna kaydeder
  }

  Future<void> _logExit(BuildContext context) async {
    await _logRepository.logAction("exit"); // firestore'a çıkış logu gönder
    signOutUser(context); // ardından oturumu kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Personel Paneli" / "Personnel Panel"
        title: Text(LocaleKeys.personnel_panel_title.tr()),
        centerTitle: true,
        actions: [
        const LanguageSwitcher(),
        IconButton(
        tooltip: LocaleKeys.auth_logout.tr(),
        icon: const Icon(Icons.logout),
        onPressed: () => _logExit(context),
   ),
 ],
      ),
      body: Center(
        child: Text(
            LocaleKeys.personnel_home_welcome.tr(),
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
