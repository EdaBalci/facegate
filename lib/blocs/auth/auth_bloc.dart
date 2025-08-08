import 'package:bloc/bloc.dart';
import 'package:facegate/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

///Bu dosyada kullanıcının giriş ve kayıt işlemlerini yönetiyorum


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;


//Constructor
  AuthBloc({required this.authRepository}) : super(AuthInitial()) { //başlangıç durumu yani giriş yapılmamış anlamına gelir "super(AuthInitial()"
    on<AuthLoginRequested>(_onLoginRequested); //Login eventi gelince _onLoginRequested fonkn çağırılıyor
    on<AuthRegisterRequested>(_onRegisterRequested); //Register eventi geldiğinde
  }

  Future<void> _onLoginRequested(
  AuthLoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading()); //login butonuna basında loading spinner göstermek için
  try {
    //firebase' giriş yapıp kullanıcının onaylı olup olmadığına bakıyorum
    final isApproved = await authRepository.loginUser(event.email, event.password);
    if (isApproved) {
      final role = await authRepository.getUserRole();
      if (role != null) {
        emit(AuthSuccess(role));
      } else {
        emit(const AuthFailure("Kullanıcı rolü bulunamadı."));
      }
    } else {
      emit(AuthWaitingApproval());
    }
  } catch (e) {
    emit(AuthFailure(e.toString()));
  }
}


  Future<void> _onRegisterRequested( //fonk authregisterrequested tetiklenince çalışmaya başlıyor
  //yani kullanıcı kayıt ol butonuna basınca
    AuthRegisterRequested event,
    Emitter<AuthState> emit, //emit() o anki statei UI'a bildirmek için kullanılır
  ) async {
    emit(AuthLoading()); //kayıt yapılıyor, loading spinner gösteriliyor
    try {
      //kullanıcıyı firebase' kaydediyor
      await authRepository.registerUser(event.email, event.password);
      emit(AuthWaitingApproval());//yeni kullanıcıyı önce onaylanmamış olarak ekliyorum, admin onayı gerekli
      //burada kullanıcı kaydoldu ve onay bekliyor
    } catch (e) {
      emit(AuthFailure(e.toString()));
      //kayıt sırasında sorun olursa
      
    }
  }
}
