import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Giriş veya çıkış log’u oluşturur
  Future<void> logAction(String action) async {
    final user = _auth.currentUser;//şu an uygulamada oturum açmış kullanıcı
    if (user == null) return;

    await _firestore.collection('logs').add({//firestoredaki logs koleksiyonunu kullanır
      'userId': user.uid,
      'email': user.email,
      'action': action, // entry veya exit
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  //tüm logları döndürür ve listeler
  Future<List<Map<String, dynamic>>> getAllLogs() async {
    //logs koleksiyonundaki tüm logları alır ve timestampa göre sıralar
    final snapshot = await _firestore //snapshot cevap objesi yani get()in sonucu
        .collection('logs')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
