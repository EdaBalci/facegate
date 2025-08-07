import 'package:cloud_firestore/cloud_firestore.dart';//kullanıcı bilg. tutmak için
import 'package:firebase_auth/firebase_auth.dart';


// Auth bloc bu sınıfı kullanır ve auth_repository firebase ile iletişime geçer
//UI->Bloc->Repository->Firebase
//Firebase işlemlerini kapsüller


//Bu iki servise ulaşmak auth_repository'nin sorumluluğu
//Bu sayede UI firebase kodlarını hiç bilmeyecek
class AuthRepository {
//firebase servislerine tek erişim noktası

  final FirebaseAuth _auth = FirebaseAuth.instance;//singleton yani tek bir örneği var
  //bellekte zaten varsa kullanılır
  //_autha sadece auth_repository.dart eriişebilir

  //veritabanı servisi
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//Kayıt işlemi, firebase auth ile kullanıcı oluşturur
  Future<void> registerUser(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    //Firestore'da users koleksiyonuna alttaki bilgilerle birlikte bir belge ekler
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'email': email,
      'role': 'personnel',
      'isApproved': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //Giriş işlemi ve onay kontrolü
  //Firebase auth ile kullanıcı giriş yapar
  //sadece admin tarafından onaylanmış personeller giriş yapabiliyor
  Future<bool> loginUser(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    //firestoredan kullanıcı datası çekilir
    final doc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    final data = doc.data();

    if (data != null && data['isApproved'] == true) {
      return true; // onaylı kullanıcı
    } else {
      await _auth.signOut(); // onaylı değilse çıkış yapılır
      return false;
    }
  

  }

  //Rolü öğrenmek için, firestoreda rol alanı okunur
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
      if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
}


}
