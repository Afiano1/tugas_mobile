import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../db/hive_manager.dart';
import '../models/user_model.dart';

class AuthService {
  /// 🔹 Enkripsi password menggunakan SHA256
  static String _encrypt(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// 🔹 REGISTER USER
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final box = HiveManager.userBox;
    final userKey = username.toLowerCase();

    // Cegah duplikasi user
    if (box.containsKey(userKey)) {
      return false; // Username sudah terdaftar
    }

    // Enkripsi password
    final encrypted = _encrypt(password);

    // Simpan user baru ke Hive
    final newUser = UserModel(
      username: username,
      email: email,
      password: encrypted,
    );

    await box.put(userKey, newUser);
    return true;
  }

  /// 🔹 LOGIN USER
  static Future<UserModel?> login(String username, String password) async {
    final userKey = username.toLowerCase();
    final user = HiveManager.userBox.get(userKey);

    if (user != null && user.password == _encrypt(password)) {
      // Simpan sesi login
      await HiveManager.sessionBox.put('isLoggedIn', true);
      await HiveManager.sessionBox.put('currentUser', userKey);
      return user;
    }

    return null; // Gagal login
  }

  /// 🔹 LOGOUT USER
  static Future<void> logout() async {
    await HiveManager.sessionBox.clear();
  }

  /// 🔹 GET CURRENT USER (cek sesi login)
  static UserModel? getCurrentUser() {
    final isLoggedIn = HiveManager.sessionBox.get('isLoggedIn') ?? false;
    final usernameKey = HiveManager.sessionBox.get('currentUser');

    if (isLoggedIn && usernameKey != null) {
      return HiveManager.userBox.get(usernameKey);
    }
    return null;
  }

  /// 🔹 Ambil semua user dari Hive
  static List<UserModel> getAllUsers() {
    final box = HiveManager.userBox;
    return box.values.toList();
  }
}
