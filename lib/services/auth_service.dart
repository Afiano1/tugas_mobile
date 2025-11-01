import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../db/hive_manager.dart';
import '../models/user_model.dart';

class AuthService {
  // Fungsi enkripsi password menggunakan SHA256
  static String _encrypt(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // REGISTER
  static Future<bool> register(
    String username,
    String password,
    String displayName,
  ) async {
    final box = HiveManager.userBox;
    final userKey = username.toLowerCase();

    if (box.containsKey(userKey)) {
      return false; // Username sudah terdaftar
    }

    final encrypted = _encrypt(password);

    await box.put(
      userKey,
      UserModel(
        username: username,
        password: encrypted,
        displayName: displayName,
      ),
    );

    return true;
  }

  // LOGIN
  static Future<UserModel?> login(String username, String password) async {
    final userKey = username.toLowerCase();
    final user = HiveManager.userBox.get(userKey);

    if (user != null && user.password == _encrypt(password)) {
      // Login berhasil, simpan session
      await HiveManager.sessionBox.put('isLoggedIn', true);
      await HiveManager.sessionBox.put('currentUser', userKey);
      return user;
    }

    return null; // Login gagal
  }

  // LOGOUT
  static Future<void> logout() async {
    await HiveManager.sessionBox.clear();
  }

  // GET CURRENT USER FOR SESSION CHECK
  static UserModel? getCurrentUser() {
    final isLoggedIn = HiveManager.sessionBox.get('isLoggedIn') ?? false;
    final usernameKey = HiveManager.sessionBox.get('currentUser');

    if (isLoggedIn && usernameKey != null) {
      // Mengambil user dari userBox menggunakan username key
      return HiveManager.userBox.get(usernameKey);
    }
    return null;
  }

  static List<UserModel> getAllUsers() {
    final box = HiveManager.userBox;
    return box.values.toList();
  }
}
