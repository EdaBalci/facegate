import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;   // Firestore'daki url
  final int? photoVersion;  // Firestore'daki photoVersion (opsiyonel ama tavsiye)
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    this.photoVersion,
    this.size = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final url = hasPhoto
        ? '${photoUrl!}${photoVersion != null ? '?v=$photoVersion' : ''}'
        : null;

    Widget img;
    if (url != null) {
      img = Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Ağ hatası olursa PNG placeholder'a düş
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/default_avatar.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    } else {
      img = Image.asset(
        'assets/images/default_avatar.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size / 2),
      child: ClipOval(child: img),
    );
  }
}
