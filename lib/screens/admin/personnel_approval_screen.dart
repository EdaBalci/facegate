import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';
import 'package:lottie/lottie.dart';

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

  //approve/reject sırasında UI durumları
  bool _isActing = false;
  String? _actingUid; // satır içi mini loader göstermek için


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
    setState(() {
      _isActing = true;   //overlay ve buton kilidi
      _actingUid = uid;   //satır içi mini loader
    });
    try {
      await _firestore.collection('users').doc(uid).update({'isApproved': true});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.personnel_approved_success.tr())),
      );
      await _fetchPendingUsers(); // listeyi yenile
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.common_error_generic.tr())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isActing = false;
          _actingUid = null;
        });
      }
    }
  }

  // reddet: kullanıcıyı sil
  Future<void> _rejectUser(String uid) async {
    setState(() {
      _isActing = true;  
      _actingUid = uid;   
    });
    try {
      await _firestore.collection('users').doc(uid).delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.personnel_rejected_success.tr())),
      );
      await _fetchPendingUsers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.common_error_generic.tr())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isActing = false;
          _actingUid = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overlay için Scaffold'ı Stack içine aldık
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.personnel_pending.tr()),
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
            actions: [translate(context),]
          ),
          body: _isLoading
              ? Center(child: _lottieLoader(size: 140))
              : _pendingUsers.isEmpty
                  ? Center(child: Text(LocaleKeys.personnel_pending_empty.tr()))
                  : ListView.builder(
                      // kaç eleman olduğunu bilmediğimiz listeler için
                      itemCount: _pendingUsers.length,
                      itemBuilder: (context, index) {
                        final user = _pendingUsers[index];
                        final email = (user['email'] as String?)?.trim();
                        final uid = user.id; // işlem için uid gerekli

                        final isRowActing = _actingUid == uid; // bu satırda işlem var mı?

                        return ListTile(
                          title: Text(
                            (email != null && email.isNotEmpty)
                                ? email
                                : LocaleKeys.common_unknown.tr(),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //satır içi mini loader 
                              if (isRowActing)
                                _lottieLoader(size: 36)
                              else ...[
                                ElevatedButton(
                                  onPressed: _isActing ? null : () => _approveUser(uid),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: Text(LocaleKeys.personnel_approve.tr()),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _isActing ? null : () => _rejectUser(uid),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text(LocaleKeys.personnel_reject.tr()),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
        ),

        //Tam ekran overlay (approve/reject sürerken)
        if (_isActing)
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
