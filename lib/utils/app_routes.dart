import 'package:facegate/screens/admin/assign_roles_screen.dart';
import 'package:facegate/screens/admin/personnel_approval_screen.dart';
import 'package:facegate/screens/splash/splash_screen.dart';
import 'package:facegate/screens/auth/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:facegate/screens/auth/register_screen.dart';
import 'package:facegate/screens/auth/waiting_approval_screen.dart';
import 'package:facegate/screens/admin/admin_home_screen.dart';
import 'package:facegate/screens/personnel/personnel_home_screen.dart';
import 'package:facegate/screens/admin/log_list_screen.dart';



class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', //uygulama ilk açıldığında açılacak sayfa
    // burada /splash deseydim diğer sayfalar gibi yönlendirilerek açılan bir ekran olurdu
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
      path: '/waiting',
      builder: (context, state) => const WaitingApprovalScreen(),
      ),
      GoRoute(
      path: '/admin/home',
      builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
      path: '/personnel/home',
      builder: (context, state) => const PersonnelHomeScreen(),
      ),
      GoRoute(
      path: '/admin/logs',
      builder: (context, state) => const LogListScreen(),
     ),
       GoRoute(
      path: '/admin/approval',
      builder: (context, state) => const PersonnelApprovalScreen(),
    ),
      GoRoute(
      path: '/admin/assign-roles',
      builder: (context, state) => const AssignRolesScreen(),
    ),
   

    ],
  );
}







