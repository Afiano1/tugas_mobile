import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';

class HiveManager {
  static late Box<UserModel> userBox;
  static late Box sessionBox;
  static late Box<BookingModel> bookingBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrasi adapter UserModel
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    // Registrasi adapter BookingModel
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BookingModelAdapter());
    }

    // --- Safe open user box ---
    try {
      userBox = await Hive.openBox<UserModel>('users');
    } catch (e) {
      print("⚠️ Terjadi error saat membuka box 'users': $e");
      await Hive.deleteBoxFromDisk('users');
      userBox = await Hive.openBox<UserModel>('users');
      print("✅ Box 'users' lama dihapus dan dibuat ulang.");
    }

    // --- Safe open session box ---
    try {
      sessionBox = await Hive.openBox('session');
    } catch (e) {
      print("⚠️ Terjadi error saat membuka box 'session': $e");
      await Hive.deleteBoxFromDisk('session');
      sessionBox = await Hive.openBox('session');
      print("✅ Box 'session' lama dihapus dan dibuat ulang.");
    }

    // --- Safe open bookings box ---
    try {
      bookingBox = await Hive.openBox<BookingModel>('bookings');
    } catch (e) {
      print("⚠️ Terjadi error saat membuka box 'bookings': $e");
      await Hive.deleteBoxFromDisk('bookings');
      bookingBox = await Hive.openBox<BookingModel>('bookings');
      print("✅ Box 'bookings' lama dihapus dan dibuat ulang.");
    }

    // =====================================================
    // 🧩 CEK STRUKTUR BARU (userEmail)
    // =====================================================
    try {
      // Jika field userEmail belum ada di data lama → reset box
      final firstBooking = bookingBox.values.isNotEmpty ? bookingBox.values.first : null;
      if (firstBooking != null && (firstBooking as dynamic).userEmail == null) {
        print("🚨 Deteksi struktur lama tanpa 'userEmail'. Melakukan reset box...");
        await Hive.deleteBoxFromDisk('bookings');
        bookingBox = await Hive.openBox<BookingModel>('bookings');
        print("✅ Struktur 'bookings' diperbarui dengan field userEmail.");
      }
    } catch (e) {
      // Jika error saat akses field → anggap struktur lama dan reset box
      print("⚠️ Error saat verifikasi struktur 'bookings': $e");
      await Hive.deleteBoxFromDisk('bookings');
      bookingBox = await Hive.openBox<BookingModel>('bookings');
      print("✅ Box 'bookings' lama dihapus dan dibuat ulang (struktur diperbarui).");
    }
  }

  /// Menghapus semua data user dan session (tanpa menghapus booking)
  static Future<void> clearAll() async {
    await userBox.clear();
    await sessionBox.clear();
  }

  /// Menghapus semua data di semua box Hive
  static Future<void> clearAllBoxes() async {
    await userBox.clear();
    await sessionBox.clear();
    await bookingBox.clear();
    print("🧹 Semua box Hive sudah dikosongkan.");
  }

  /// Reset seluruh Hive (hapus semua box dari disk)
  static Future<void> resetHive() async {
    await Hive.deleteFromDisk();
    print("🔥 Semua data Hive dihapus dari disk!");
  }
}
