import 'dart:ui';
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




final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // EasyLocalization başlatma (JSON'ları okumak için gerekli)
  await EasyLocalization.ensureInitialized();

  // Firebase başlatma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalAvatarStore.init(); //Hive box açılır
    await analytics.logEvent(name: 'app_start');
     // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

  final authRepository = AuthRepository(); // AuthBloc'a vereceğim AuthRepository nesnesi
  //Auth işlemleri merkezi olarak tek bir yerden yönetilecek
  //AuthRepository sayesinde AuthBloc firebase yerine başka bir auth servisiyle de çalışabilir
  //Başka bir auth servisi kullanmak istediğimde sadece repositoryi değiştirmem gerek bloc ve UI aynı kalacak

  runApp(
    // EasyLocalization en dışa sarıldı ki altındaki tüm widget ağaçlarında locale bilgisi erişilebilir olsun
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')], // desteklenen diller
      path: 'assets/lang', // çeviri dosyalarının yolu
      fallbackLocale: const Locale('en'), // dil bulunamazsa varsayılan
      saveLocale: true, // seçimi kalıcı tut
      assetLoader: const CodegenLoader(), // codegen_loader.g.dart kullan (hızlı ve güvenli)
      child: BlocProvider<AuthBloc>(
        //AuthBloc adında bir bloc objesi oluşturdum bu obje tüm app için erişilebilir halde
        //BlocProvider burada bloc objesini uygulamanın bir üst widget ağacına sağlıyor
        //Bu şekilde diğer ekranlarda AuthBloc yaratmama gerek kalmayacak
        create: (context) => AuthBloc(authRepository: authRepository),
        //AuthBloc objesi oluşturup buna AuthRepository'i enjekte ettim
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
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router, //app_routes.dart'daki route yapılarını kullanmak için
      title: 'FaceGate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      // easy_localization: MaterialApp'e locale/degates/supportedLocales bağları
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
