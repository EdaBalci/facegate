import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:facegate/widgets/language_switcher.dart';

// i18n
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

class PersonnelApprovalScreen extends StatefulWidget {
  const PersonnelApprovalScreen({super.key});

  @override
  State<PersonnelApprovalScreen> createState() =>
      _PersonnelApprovalScreenState();
}

class _PersonnelApprovalScreenState extends State<PersonnelApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // firestore bağlantısı
  bool _isLoading = true;
  List<DocumentSnapshot> _pendingUsers = []; // onay bekleyen personeller

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers(); // sayfa ilk açıldığında verileri çek
  }

  // firestore'da users koleksiyonunda role=personnel, isApproved=false olanları getir
  Future<void> _fetchPendingUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'personnel')
        .where('isApproved', isEqualTo: false)
        .get();

    setState(() {
      _pendingUsers = snapshot.docs;
      _isLoading = false;
    });
  }

  // kullanıcı uid'sine göre isApproved=true yap (onayla)
  Future<void> _approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({'isApproved': true});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.personnel_approved_success.tr())),
    );
    _fetchPendingUsers(); // listeyi yenile
  }

  // reddet: kullanıcıyı sil
  Future<void> _rejectUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.personnel_rejected_success.tr())),
    );
    _fetchPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.personnel_pending.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/home'),
        ),
        actions: const [LanguageSwitcher()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? Center(child: Text(LocaleKeys.personnel_pending_empty.tr()))
              : ListView.builder(
                  // kaç eleman olduğunu bilmediğimiz listeler için
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    final email = (user['email'] as String?)?.trim();
                    final uid = user.id; // işlem için uid gerekli

                    return ListTile(
                      title: Text(
                        (email != null && email.isNotEmpty)
                            ? email
                            : LocaleKeys.common_unknown.tr(),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _approveUser(uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: Text(LocaleKeys.personnel_approve.tr()),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectUser(uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(LocaleKeys.personnel_reject.tr()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
