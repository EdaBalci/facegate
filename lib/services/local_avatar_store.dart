import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class LocalAvatarStore {
  static const _boxName = 'user_profile';
  static const _keyPrefix = 'avatar_';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static String? getPhotoPath(String uid) {
    return _box.get('$_keyPrefix$uid') as String?;
  }

  static ValueListenable<Box> listenableFor(String uid) {
    return _box.listenable(keys: ['$_keyPrefix$uid']);
  }

  static Future<String> savePickedImage(String uid, File pickedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    final targetPath = '${profileDir.path}/$uid${_safeExt(pickedFile.path)}';

   
    await pickedFile.copy(targetPath);

    await _box.put('$_keyPrefix$uid', targetPath);
    return targetPath;
  }

  static Future<void> clear(String uid) async {
    await _box.delete('$_keyPrefix$uid');
  }

  static String _safeExt(String path) {
    final i = path.lastIndexOf('.');
    if (i == -1) return '.jpg';
    final e = path.substring(i).toLowerCase();
    if (e.length > 6 || RegExp(r'[^a-z0-9\.]').hasMatch(e)) return '.jpg';
    return e;
  }
}
