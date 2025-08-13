  import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

IconButton translate(BuildContext context) {
    return IconButton(
          tooltip: 'Change Language',
          icon:  Icon(Icons.language),
          onPressed: () async {
            final isTR = context.locale.languageCode == 'tr';

            //EasyLocalization’a dili değiştir diyor ve widget ağacı yeniden çiziliyor
            await context.setLocale(Locale(isTR ? 'en' : 'tr')); 
          },
        );
  }
