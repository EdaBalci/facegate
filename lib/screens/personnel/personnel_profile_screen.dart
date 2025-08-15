import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facegate/repositories/user_repository.dart';
import 'package:facegate/widgets/user_avatar_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:facegate/widgets/translate_switcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:facegate/services/local_avatar_store.dart';

class PersonnelProfileScreen extends StatefulWidget {
  const PersonnelProfileScreen({super.key});

  @override
  State<PersonnelProfileScreen> createState() => _PersonnelProfileScreenState();
}

class _PersonnelProfileScreenState extends State<PersonnelProfileScreen> {
  final _repo = UserRepository(); // users/{uid} stream + foto yükleme
  //foto artık local saklanıyor Firestore sadece rol/görev için kullanılıyor.
  final _picker = ImagePicker();
  bool _uploading = false;

  //lokal dosya yolu için uid
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _changePhoto() async {
//fotoğraf seç ve yerel olarak kaydet
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      setState(() => _uploading = true);
      // yerel kopyalama 
      await LocalAvatarStore.savePickedImage(_uid, File(picked.path));

      if (mounted) { //mounted kontrolü
      //widget hala aktif mi ve hala ekranda var mı kontrol eder
      //yoksa setstate hiç çalışmaz, varsa çalışır ve UI güncellenir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.profile_photo_updated.tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  // Firestore'da "operator" / "security" ya da doğrudan TR/EN metin gelebilir.
  // Her iki durumda da i18n etiketini döndürür tanınmazsa gelen metni aynen gösterir
  String _roleLabel(dynamic roleRaw) {
    final raw = (roleRaw ?? '').toString().trim();
    if (raw.isEmpty) return LocaleKeys.admin_roles_not_assigned.tr();

    final rawLower = raw.toLowerCase();
    final opTrLower = LocaleKeys.admin_roles_operator.tr().toLowerCase();
    final secTrLower = LocaleKeys.admin_roles_security.tr().toLowerCase();

    if (rawLower == 'operator' || rawLower == opTrLower) {
      return LocaleKeys.admin_roles_operator.tr();
    }
    if (rawLower == 'security' || rawLower == secTrLower) {
      return LocaleKeys.admin_roles_security.tr();
    }
    // farklı bir değer yazıldıysa eski veriler gibi olduğu gibi göster
    return raw;
  }

  //Firestore'da gorev varsa onu göster; yoksa role etiketine düş.
  String _dutyFromRoleOrGorev({String? role, String? gorev}) {
    if (gorev != null && gorev.trim().isNotEmpty) {
      return gorev.trim();
    }
    return _roleLabel(role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // "Profil" / "Profile"
        title: Text(LocaleKeys.profile_title.tr()),
        centerTitle: true,
        actions: [
          // dil seçici (mevcut)
          translate(context),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _repo.userDocStream(), // users/{uid} belgesini canlı dinler
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snap.data?.data() ?? {}; 
          final name = (data['displayName'] as String?) ?? '—';

          // Firestore alanları
          final rawRole = data['role'] as String?;   // "operator" | "security" | metin
          final gorev   = data['gorev'] as String?;  // serbest metin görev

          final roleLabel = _roleLabel(rawRole);
          final dutyText  = _dutyFromRoleOrGorev(role: rawRole, gorev: gorev);

          //Lokal avatarı dinle ki foto değişince anında yenilensin
          return ValueListenableBuilder(
            valueListenable: LocalAvatarStore.listenableFor(_uid),
            builder: (context, box, _) {
              final localPath = LocalAvatarStore.getPhotoPath(_uid);

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Profil fotoğrafı varsa lokaldeki yoksa svg placeholder
                        UserAvatarSvg(localPath: localPath, size: 96),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton.filled(
                            onPressed: _uploading ? null : _changePhoto,
                            icon: _uploading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.edit),
                            tooltip: LocaleKeys.profile_change_photo.tr(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(name, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 24),

                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: Text(LocaleKeys.admin_roles_current_role.tr()),
                    subtitle: Text(roleLabel),
                  ),
                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.assignment),
                    title: Text(LocaleKeys.profile_duty_title.tr()),
                    subtitle: Text(dutyText),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
