import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:facegate/repositories/log_repository.dart';

////Eğer kullanıcı AuthBloc üzerinden AuthSuccess("personnel") durumu ile giriş yaptıysa


class PersonnelHomeScreen extends StatefulWidget {
  const PersonnelHomeScreen({super.key});

  @override
  State<PersonnelHomeScreen> createState() => _PersonnelHomeScreenState();
}

class _PersonnelHomeScreenState extends State<PersonnelHomeScreen> {
  final LogRepository _logRepository = LogRepository(); //firestore'a log yazmak için

  @override
  void initState() {
    super.initState();
    _logEntry(); //giriş logunu firestorea yazan fonk çağırır
  }

  Future<void> _logEntry() async {
    await _logRepository.logAction("entry"); //giriş yapan kullanıcıyı logs koleksiyonuna kaydeder
  }

  Future<void> _logExit(BuildContext context) async {
    await _logRepository.logAction("exit");//firestorea çıkış logu gönderir
    signOutUser(context); // çıkış yaptıktan sonra oturumu kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personel Paneli'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logExit(context), //butona basınca çıkış logu gönderir
          ),
        ],
      ),
      body: const Center(
        child: Text(
          ' ',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
