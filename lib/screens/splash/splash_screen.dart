
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


//StatefulWidget çünkü initState() içinde zamanlayıcı ile yönlendirme olacak
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //login sayfasına yönlendirecek (5 saniyeye ayarladım)
    Future.delayed(const Duration(seconds: 5), () {
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'FaceGate',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
