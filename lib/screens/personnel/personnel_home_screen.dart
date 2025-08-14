import 'package:facegate/utils/helpers.dart';
import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:facegate/repositories/log_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

// EKLENDİ: profil butonu için gerekli importlar
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:facegate/repositories/user_repository.dart';
import 'package:facegate/widgets/user_avatar.dart';

/// Eğer kullanıcı AuthBloc üzerinden AuthSuccess("personnel") durumu ile giriş yaptıysa
class PersonnelHomeScreen extends StatefulWidget {
  const PersonnelHomeScreen({super.key});

  @override
  State<PersonnelHomeScreen> createState() => _PersonnelHomeScreenState();
}

class _PersonnelHomeScreenState extends State<PersonnelHomeScreen> {
  final LogRepository _logRepository = LogRepository(); // firestore'a log yazmak için
  // EKLENDİ: users/{uid} belgesini dinlemek ve avatar göstermek için
  final UserRepository _userRepository = UserRepository(); // profil/görev/rol stream

  @override
  void initState() {
    super.initState();
    _logEntry(); // giriş logunu firestore'a yaz
  }

  Future<void> _logEntry() async {
    await _logRepository.logAction("entry"); // giriş yapan kullanıcıyı logs koleksiyonuna kaydeder
    // NOT: Burada herhangi bir "girişiniz kaydedildi" snackbar/metin gösterilmiyor (kaldırıldı)
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
         
          translate(context),

          //Profil butonu (avatar). users/{uid} Firestore belgesini canlı dinler
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _userRepository.userDocStream(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final String? photoUrl = data?['photoUrl'] as String?;
              final int? photoVersion = data?['photoVersion'] as int?;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: UserAvatar(
                  photoUrl: photoUrl,
                  photoVersion: photoVersion, 
                  size: 32, 
                  onTap: () => context.push('/personnel/profile'),
                ),
              );
            },
          ),

   
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
