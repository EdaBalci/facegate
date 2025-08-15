import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserAvatarSvg extends StatelessWidget {
  final String? localPath;   // cihazdaki dosya yolu (Hive’dan gelir)
  final double size;
  final VoidCallback? onTap;

  const UserAvatarSvg({
    super.key,
    required this.localPath,
    this.size = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = (localPath != null && localPath!.isNotEmpty) ? File(localPath!) : null;

    Widget child;
    if (file != null && file.existsSync()) {
      child = Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => SvgPicture.asset('assets/images/default_avatar.svg', fit: BoxFit.cover),
      );
    } else {
      child = SvgPicture.asset('assets/images/default_avatar.svg', fit: BoxFit.cover);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: ClipOval(
        child: SizedBox(width: size, height: size, child: child),
      ),
    );
  }
}
