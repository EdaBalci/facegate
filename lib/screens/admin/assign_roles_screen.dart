import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:lottie/lottie.dart';

class AssignRolesScreen extends StatefulWidget {
  const AssignRolesScreen({super.key});

  @override
  State<AssignRolesScreen> createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<DocumentSnapshot> _personnel = [];
  List<DocumentSnapshot> _filteredPersonnel = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  //dbye bunlar yazılır
  final List<String> _roleCodes = ['operator', 'security'];

  //Geriye dönük kayıtlar için (DB'de eski metinler varsa) eşleme
  static const Map<String, String> _legacyRoleToCode = {
    // TR
    'Sunucu Odası Operatörü': 'operator',
    'Veri Güvenliği Uzmanı': 'security',
    // EN (olası eski kayıtlar)
    'Server Room Operator': 'operator',
    'Data Security Specialist': 'security',
  };

  //Rol atama esnasında overlay/mini-loader yönetimi için bayraklar
  bool _isAssigning = false;
  String? _savingUserId;

  //Tek yerden kullanacağımız Lottie loader helper'ı
  Widget _lottieLoader({double size = 120}) {
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

  @override
  void initState() {
    super.initState();
    _fetchApprovedPersonnel();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Firestore'dan onaylı personelleri getir, admin hariç
  Future<void> _fetchApprovedPersonnel() async {
    final currentUserEmail = _auth.currentUser?.email;

    final snapshot = await _firestore
        .collection('users')
        .where('isApproved', isEqualTo: true)
        .get();

    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      return data['email'] != currentUserEmail;
    }).toList();

    setState(() {
      _personnel = filtered;
      _filteredPersonnel = filtered;
      _isLoading = false;
    });
  }

  // Email ile filtreleme yap
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPersonnel = _personnel.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final email = (data['email'] ?? '').toString().toLowerCase();
        return email.contains(query);
      }).toList();
    });
  }

  // Rol kodu, ekranda gösterilecek yerelleştirilmiş label
  String _labelForRoleCode(String code) {
    switch (code) {
      case 'operator':
        return LocaleKeys.admin_roles_operator.tr();
      case 'security':
        return LocaleKeys.admin_roles_security.tr();
      default:
        return code; // bilinmeyen kod varsa olduğu gibi göster
    }
  }

  // DB'den gelen string'i kanonik koda çevir (eski TR/EN kayıtlar için)
  String? _normalizeRole(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString();
    if (_roleCodes.contains(value)) return value; // zaten kod
    return _legacyRoleToCode[value]; // eski metin -> kod
  }

  // Firestore'da görevi güncelle (kanonik rol kodu yazar)
  Future<void> _assignRole(String userId, String roleCode) async {
    setState(() {
      _isAssigning = true;   // overlay'i aç
      _savingUserId = userId; // satır içi mini loader için
    });

    try {
      await _firestore.collection('users').doc(userId).update({
        'gorev': roleCode, // kanonik kod olarak kaydet
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.admin_roles_assigned_success.tr())),
      );

      await _fetchApprovedPersonnel(); // listeyi yenile
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAssigning = false; // overlay'i kapat
          _savingUserId = null; 
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Overlay için Scaffold'ı Stack içine aldık
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            // "Görev Atama" / "Assign Role"
            title: Text(LocaleKeys.admin_roles_assign_role_title.tr()),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  context.pop();
                } else {
                  context.go('/admin/home');
                }
              },
            ),
            actions: [translate(context)],
          ),
          body: _isLoading
              ? Center(child: _lottieLoader(size: 140)) 
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.common_search_by_email.tr(),
                          prefixIcon: const Icon(Icons.search),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _filteredPersonnel.isEmpty
                          ? Center(child: Text(LocaleKeys.common_no_results.tr()))
                          : ListView.builder(
                              itemCount: _filteredPersonnel.length,
                              itemBuilder: (context, index) {
                                final userDoc = _filteredPersonnel[index];
                                final userData =
                                    userDoc.data() as Map<String, dynamic>;
                                final email =
                                    (userData['email'] as String?)?.trim();
                                final userId = userDoc.id;

                                // DB'deki 'gorev' alanını normalize et (kod'a çevir)
                                final currentRoleCode =
                                    _normalizeRole(userData['gorev']);

                                // bu satır için kaydetme sürüyorsa mini loader göster
                                final isRowSaving = _savingUserId == userId;

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: ListTile(
                                    title: Text(
                                      (email != null && email.isNotEmpty)
                                          ? email
                                          : LocaleKeys.common_unknown.tr(),
                                    ),
                                    subtitle: Text(
                                      LocaleKeys.admin_roles_current_role.tr(
                                        namedArgs: {
                                          'role': currentRoleCode == null
                                              ? LocaleKeys
                                                  .admin_roles_not_assigned
                                                  .tr()
                                              : _labelForRoleCode(
                                                  currentRoleCode,
                                                ),
                                        },
                                      ),
                                    ),
                                    trailing: isRowSaving
                                        ? _lottieLoader(size: 36) //satır içi mini loader
                                        : DropdownButton<String>(
                                            value: _roleCodes
                                                    .contains(currentRoleCode)
                                                ? currentRoleCode
                                                : null,
                                            hint: Text(LocaleKeys
                                                .admin_roles_assign_role_hint
                                                .tr()),
                                            items: _roleCodes.map((code) {
                                              return DropdownMenuItem<String>(
                                                value: code,
                                                child:
                                                    Text(_labelForRoleCode(code)),
                                              );
                                            }).toList(),
                                            onChanged: (selectedCode) {
                                              if (selectedCode != null) {
                                                _assignRole(userId, selectedCode);
                                              }
                                            },
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),

        //Tam ekran overlay (rol atama esnasında)
        if (_isAssigning)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black54,
              child: Center(child: _lottieLoader(size: 140)),
            ),
          ),
      ],
    );
  }
}
