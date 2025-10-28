import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveManager {
  static late Box<UserModel> userBox;
  static late Box sessionBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Daftarkan adapter UserModel (penting!)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Buka box data pengguna dan session
    userBox = await Hive.openBox<UserModel>('users');
    sessionBox = await Hive.openBox('session');
  }

  static Future<void> clearAll() async {
    await userBox.clear();
    await sessionBox.clear();
  }
}
