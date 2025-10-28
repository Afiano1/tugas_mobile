import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../db/hive_manager.dart';
import '../models/user_model.dart';

class AuthService {
  static String _encrypt(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<bool> register(String username, String password, String country) async {
    final box = HiveManager.userBox;

    // Cek apakah username sudah ada
    if (box.values.any((u) => u.username.toLowerCase() == username.toLowerCase())) {
      return false;
    }

    final encrypted = _encrypt(password);
    await box.add(UserModel(username: username, password: encrypted, country: country));
    return true;
  }

  static Future<UserModel?> login(String username, String password) async {
    final box = HiveManager.userBox;
    final encrypted = _encrypt(password);

    try {
      return box.values.firstWhere(
        (u) =>
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == encrypted,
      );
    } catch (e) {
      return null;
    }
  }

  static List<UserModel> getAllUsers() {
    final box = HiveManager.userBox;
    return box.values.toList();
  }
}
