import 'package:facegate/utils/helpers.dart';
import 'package:flutter/material.dart';


class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(), //title'ı gizlemek için
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOutUser(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Başvurunuz admin onayı bekliyor",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
