import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


//Firebase Authenticationdan çıkış yapıp login ekranına yönlendirme
void signOutUser(BuildContext context) async { //context sayfa yönlendirme yapmak için
  await FirebaseAuth.instance.signOut();

  context.go('/login');
}
