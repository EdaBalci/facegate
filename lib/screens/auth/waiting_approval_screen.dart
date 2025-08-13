import 'package:facegate/utils/helpers.dart';
import 'package:facegate/widgets/translate_switcher.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facegate/l10n/locale_keys.g.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: const SizedBox.shrink(),
        actions: [
          translate(context),
          IconButton(
            tooltip: LocaleKeys.auth_logout.tr(),
            icon: const Icon(Icons.logout),
            onPressed: () => signOutUser(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          LocaleKeys.auth_waiting_message.tr(),
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
