import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';

class HiveManager {
  static late Box<UserModel> userBox;
  static late Box sessionBox;
  static late Box<BookingModel> bookingBox; // Box untuk menyimpan data booking

  static Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    // FIX: Daftarkan adapter BookingModel
    if (!Hive.isAdapterRegistered(1)) { 
      Hive.registerAdapter(BookingModelAdapter()); 
    }

    userBox = await Hive.openBox<UserModel>('users');
    sessionBox = await Hive.openBox('session'); 
    bookingBox = await Hive.openBox<BookingModel>('bookings'); // Buka box baru
  }

  static Future<void> clearAll() async {
    await userBox.clear();
    await sessionBox.clear();
  }
}