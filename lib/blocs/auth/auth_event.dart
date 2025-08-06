import 'package:equatable/equatable.dart';


//Bloc'un çalışabilmesi için kullanıcıdan gelen eventleri dinlemesi gerek 
//Bu dosyada da kullanıcıdan gelen eventleri tanımlıyorum
//Bloc bunları dinler ve logical işlemi ona göre yapar


//abstract olduğu için bu sınıf doğrudan kullanılmaz 
//bu sınıfı extend eden sınıflar kullanır
//Equatable sınıfı sayesinde iki AuthEvent nesnesi karşılaştırılabilir hale geliyor
abstract class AuthEvent extends Equatable {
  const AuthEvent();
}


//kullanıcı giriş yap butonuna basınca tetiklenir
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];//Equatable'ın aynı olup olmadığını belirlemek için baktığı nesneler
  //diyelim ki 2 kere kayıt ola bastı ya da event yanlışlıkla 2 kez gönderildi 
  //aynı email pass gönderilirse build edilmemesi için
}

//kullanıcı kayıt ol butonuna bastığında tetiklenir
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthRegisterRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}


