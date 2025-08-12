import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: () async {
        final isTR = context.locale.languageCode == 'tr';
        await context.setLocale(Locale(isTR ? 'en' : 'tr'));
      },
    );
  }
}
