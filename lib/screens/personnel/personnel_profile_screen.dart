import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facegate/repositories/user_repository.dart';
import 'package:facegate/widgets/user_avatar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:facegate/widgets/translate_switcher.dart';

class PersonnelProfileScreen extends StatefulWidget {
  const PersonnelProfileScreen({super.key});

  @override
  State<PersonnelProfileScreen> createState() => _PersonnelProfileScreenState();
}

class _PersonnelProfileScreenState extends State<PersonnelProfileScreen> {
  final _repo = UserRepository(); // users/{uid} stream + foto yükleme
  final _picker = ImagePicker();
  bool _uploading = false;

  Future<void> _changePhoto() async {
    // Galeriden PNG/JPG seç, Storage'a yükle, Firestore'a URL yaz
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      setState(() => _uploading = true);
      await _repo.uploadProfilePhoto(File(picked.path));
      if (mounted) {
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
  // Her iki durumda da i18n etiketini döndürür; tanınmazsa gelen metni aynen gösterir.
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
    // farklı bir değer yazıldıysa (ör. eski veriler), olduğu gibi göster
    return raw;
  }

  /// GÖREV METNİ — Firestore'da gorev varsa onu göster; yoksa role etiketine düş.
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
   
        title: Text(LocaleKeys.profile_title.tr()),
        centerTitle: true,
        actions: [
     
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
          final photoUrl = data['photoUrl'] as String?;
          final photoVersion = data['photoVersion'] as int?;
          final name = (data['displayName'] as String?) ?? '—';

          // Firestore alanları
          final rawRole = data['role'] as String?;   // "operator" | "security" | metin
          final gorev   = data['gorev'] as String?;  // serbest metin görev

          final roleLabel = _roleLabel(rawRole);
          final dutyText  = _dutyFromRoleOrGorev(role: rawRole, gorev: gorev);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    // Profil fotoğrafı (PNG fallback'li)
                    UserAvatar(photoUrl: photoUrl, photoVersion: photoVersion, size: 96),
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
      ),
    );
  }
}
