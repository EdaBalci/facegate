// lib/repositories/user_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Oturum açmış kullanıcının UID'i (yoksa Exception fırlatır)
  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No signed-in user');
    return uid;
  }

  /// users/{uid} referansı (tekrar kullanmak için)
  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  /// users/{uid} belgesini CANLI dinler (profil, rol/görev, foto vs.)
  Stream<DocumentSnapshot<Map<String, dynamic>>> userDocStream() {
    return _userDoc.snapshots();
  }

  /// users/{uid} belgesini tek sefer okur
  Future<Map<String, dynamic>?> getUserData() async {
    final doc = await _userDoc.get();
    return doc.data();
  }

  /// Profil fotoğrafını Firebase Storage'a yükler ve Firestore'a URL'i yazar.
  /// - Benzersiz dosya adı kullanır (cache çakışmasını önler)
  /// - Belge yoksa set(merge:true) ile oluşturur
  /// - photoVersion'ı artırır (UI cache-bust)
  Future<String> uploadProfilePhoto(File file) async {
    try {
      final String ext = _safeExt(file.path); // .jpg/.png/.heic vs.
      final String filename = 'profile_${DateTime.now().millisecondsSinceEpoch}$ext';
      final Reference ref = _storage.ref().child('users').child(_uid).child(filename);

      // İçerik tipi ver (Storage kurallarında image/* kontrolü varsa gerekli)
      final metadata = SettableMetadata(contentType: _contentTypeForExt(ext));

      // 1) Dosyayı yükle
      await ref.putFile(file, metadata);

      // 2) URL al
      final String url = await ref.getDownloadURL();

      // 3) Firestore'a yaz (BELGE YOKSA BİLE OLUŞUR)
      await _userDoc.set({
        'photoUrl': url,
        'photoUpdatedAt': FieldValue.serverTimestamp(),
        'photoVersion': FieldValue.increment(1),
      }, SetOptions(merge: true));

      return url;
    } on FirebaseException catch (e) {
      // Teşhis için konsola yaz
      // ignore: avoid_print
      print('uploadProfilePhoto FirebaseException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('uploadProfilePhoto error: $e');
      rethrow;
    }
  }

  /// Dosya uzantısını güvenli çıkarma (package:path kullanmadan)
  String _safeExt(String path) {
    final i = path.lastIndexOf('.');
    if (i == -1) return '.jpg';
    final e = path.substring(i).toLowerCase();
    // Çok uzun/garip uzantılarda .jpg'e düş
    if (e.length > 6 || e.contains(RegExp(r'[^a-z0-9\.]'))) return '.jpg';
    return e;
  }

  /// Uzantıya göre içerik tipi (Storage rules 'image/*' kontrolü için)
  String _contentTypeForExt(String ext) {
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.heic':
        // iOS galerisi HEIC verebilir
        return 'image/heic';
      case '.webp':
        return 'image/webp';
      default:
        // emin değilsek jpeg'e düş (rules image/* ile uyumlu)
        return 'image/jpeg';
    }
  }
}
