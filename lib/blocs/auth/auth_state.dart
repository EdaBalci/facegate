import 'package:equatable/equatable.dart';

//AuthBloc tarafından üretilen stateler


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {} //uygulama ilk açıldıpında ya da oturum kapatıldığındaki durum

class AuthLoading extends AuthState {} //giriş ve kayıt işlemi sırasındaki durum
//loading spinner

class AuthWaitingApproval extends AuthState {}
//kullanıcı kayıt oldu ve adminden onay bekliyor

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthSuccess extends AuthState {
  final String role; //firebaseden admin veya personnel rolü çekilir. 
  //bunu kullanarak ilgili sayfaya yönlendirilir
  const AuthSuccess(this.role);

  @override
  List<Object?> get props => [role];
}

