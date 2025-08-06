import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class PersonnelApprovalScreen extends StatefulWidget {
  const PersonnelApprovalScreen({super.key});

  @override
  State<PersonnelApprovalScreen> createState() => _PersonnelApprovalScreenState();
}

class _PersonnelApprovalScreenState extends State<PersonnelApprovalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; //firestore bağlantısı
  bool _isLoading = true;
  List<DocumentSnapshot> _pendingUsers = []; //firestoredan gelen onay bekleyen personeller list

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers(); //sayfa ilk açıldığında bu fonk çağırıyoruz
    //firestoredan verileri çekmeye başlıyor
  }

//firestoreda users koleksiyonuna gider
  Future<void> _fetchPendingUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'personnel')
        .where('isApproved', isEqualTo: false)
        .get();

    setState(() {
      _pendingUsers = snapshot.docs;
      _isLoading = false; //false olanları listeliyor yani onay bekleyenler
    });
  }

//kullanıcı uid'sine göre isApproved değerini true yapar onaylamak için
  Future<void> _approveUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isApproved': true,
    });
    _fetchPendingUsers();//kullanıcı listesini güncellemek için tekrar çağırıyoruz
  }

  Future<void> _rejectUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete(); //reddedilen kullanıcıyı firestoredan siler
    _fetchPendingUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onay Bekleyen Personeller'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin/home');
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? const Center(child: Text('Onay bekleyen personel yok.'))
              : ListView.builder(//kaç elemanı olduğu bilinmeyen listeleri çizmek için kullanılır
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index]; 
                    final email = user['email'] ?? 'Bilinmeyen';
                    final uid = user.id;//firestoreda kullanıcıya bir işlem yapmak istiyordan uid'sini bilmen gerekir

                    return ListTile(
                      title: Text(email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _approveUser(uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Onayla'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _rejectUser(uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Reddet'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

