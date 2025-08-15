import 'dart:ui';
import 'dart:async';
import 'package:facegate/blocs/auth/auth_bloc.dart';
import 'package:facegate/firebase_options.dart';
import 'package:facegate/repositories/auth_repository.dart'; // bloc doğrudan firebase'den değil bu repository üzerinden işlem yapar
import 'package:facegate/utils/app_routes.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/codegen_loader.g.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:facegate/services/local_avatar_store.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

//SnackBar gösterebilmek için ScaffoldMessenger anahtarı
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Uygulama geneli online offline bilgisini paylaşmak için global notifier
final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization başlatma (JSON'ları okumak için gerekli)
  await EasyLocalization.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalAvatarStore.init(); //Hive box açılır yerel depolama
  await analytics.logEvent(name: 'app_start');

  // Framework seviyesindeki yakalanmamış hataları Crashlytics'e ilet
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Framework dışı async hataları Crashlytics'e ilet
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final authRepository = AuthRepository(); // AuthBloc'a vereceğim AuthRepository nesnesi

  runApp(
    // EasyLocalization en dışa sarıldı ki altındaki tüm widget ağaçlarında locale bilgisi erişilebilir olsun
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')], // desteklenen diller
      path: 'assets/lang', // çeviri dosyalarının yolu
      fallbackLocale: const Locale('en'), // dil bulunamazsa varsayılan
      saveLocale: true, // seçimi kalıcı tut
      assetLoader: const CodegenLoader(),

      // Tüm uygulamayı internet izleyicisi ile sardık (SnackBar + isOnlineNotifier güncelleme)
      child: ConnectionWatcher(
        child: BlocProvider<AuthBloc>(
          // AuthBloc adında bir bloc objesi oluşturdum; uygulama genelinden erişilecek
          create: (context) => AuthBloc(authRepository: authRepository),
          child: ScreenUtilInit(
            designSize: const Size(393, 852),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return const MyApp();
            },
          ),
        ),
      ),
    ),
  );
}

// Online/Offline olduğunda SnackBar mesajı gösterir ve isOnlineNotifier'ı günceller.
class ConnectionWatcher extends StatefulWidget {
  //stateless olsa dinlemeyi iptal edemezdik çünkü initState ya da dispose yok
  final Widget child;
  const ConnectionWatcher({super.key, required this.child});

  @override
  State<ConnectionWatcher> createState() => _ConnectionWatcherState();
}

class _ConnectionWatcherState extends State<ConnectionWatcher> {
  StreamSubscription<InternetConnectionStatus>? _sub;
  bool? _lastConnected;

  @override
  void initState() {//abonelik
    super.initState();
    _startListening();
  }

  Future<void> _startListening() async {
    // Açılışta bir kere anlık kontrol kullanıcı uygulamayı offline başlatırsa da mesaj görsün
    final hasNet = await InternetConnectionChecker.instance.hasConnection;
    _lastConnected = hasNet;
    isOnlineNotifier.value = hasNet; // Uygulama geneline duyur
    if (!hasNet) {
      _showSnackBar('İnternet bağlantınız kesildi!');
    }

    // Durum değişimlerini dinle
    _sub = InternetConnectionChecker.instance.onStatusChange.listen((status) {
      final connected = status == InternetConnectionStatus.connected;

      // Sadece değişiklik olduğunda mesaj göster
      if (_lastConnected == true && connected == false) {
        _showSnackBar('İnternet bağlantınız kesildi!');
      } else if (_lastConnected == false && connected == true) {
        _showSnackBar('İnternet bağlantınız geri geldi.');
      }

      _lastConnected = connected;
      isOnlineNotifier.value = connected; // Uygulama geneline duyurmak için
    });
  }

  void _showSnackBar(String message) { 
    scaffoldMessengerKey.currentState?.showSnackBar(//ConnectionWatcher Materialapp'in üstünde bu yüzden ScaffoldMessenger.of(context) kullanamıyor
      const SnackBar(
        //içerik metni dışarıdan verilecek
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        content: Text(''), // placeholder, aşağıda override edeceğiz
      ),
    );

    // Son gösterilen SnackBar'ı gizleyip yenisini göster (içeriği doğru yazmak için)
    scaffoldMessengerKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() { //abonelik iptali
  //iptal önemli çünkü etmezsen ekran kapansa bile dinlemeye devam eder, memıry leak
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // isOnlineNotifier'ı dinleyip tüm uygulamayı AbsorbPointer ile sarıyoruz.
    // Offline iken absorbing true ve tüm tıklamalar/bloklar devre dışı.
    return ValueListenableBuilder<bool>(
      valueListenable: isOnlineNotifier,
      builder: (context, isOnline, _) {
        return AbsorbPointer(
          absorbing: !isOnline, //tüm butonlar devre dışı
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router, // app_routes.dart'daki route yapılarını kullanmak için
            title: 'FaceGate',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            ),

            // easy_localization: MaterialApp'e locale/delegates/supportedLocales bağları
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            // SnackBar'ı yukarıdan tetiklemek için messenger anahtarı
            scaffoldMessengerKey: scaffoldMessengerKey,
          ),
        );
      },
    );
  }
}

//Overlay normal widget ağacının dışında çalışır
//Overlay widget’lar sahnenin üzerine şeffaf gibi eklenir
