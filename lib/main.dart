import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'db/hive_manager.dart';
import 'models/user_model.dart';
import 'models/hotel_model.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/hotel_search_page.dart';
import 'pages/hotel_detail_page.dart';
import 'screen/main_screen.dart';

// 🔔 Global notifikasi plugin (harus bisa diakses dari file lain)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _initializeNotifications() async {
  // 🔹 Setup dasar notifikasi
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 🔹 Buat channel untuk Android
  const androidChannel = AndroidNotificationChannel(
    'booking_channel',
    'Booking Notifications',
    description: 'Notifikasi pemesanan hotel',
    importance: Importance.max,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  // ✅ Buat channel jika belum ada
  await androidPlugin?.createNotificationChannel(androidChannel);

  // ✅ Minta izin tampilkan notifikasi (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<Widget> _getInitialPage() async {
  final UserModel? user = AuthService.getCurrentUser();
  if (user != null) {
    return MainScreen(user: user);
  } else {
    return const LoginPage();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Muat variabel lingkungan dari file .env
  await dotenv.load(fileName: ".env");

  // ✅ Inisialisasi Hive
  await Hive.initFlutter();
  await HiveManager.init();

  // ✅ Inisialisasi timezone & notifikasi
  tz.initializeTimeZones();
  await _initializeNotifications();

  // ✅ Tentukan halaman awal
  final initialPage = await _getInitialPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hotel Booking App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: initialPage,

      // ✅ Tambahkan definisi routes di sini
      routes: {
        '/hotel_search': (context) => const HotelSearchPage(),

        // ✅ Rute untuk halaman detail hotel
        '/hotel_detail': (context) {
          final hotel =
              ModalRoute.of(context)!.settings.arguments as HotelModel;
          return HotelDetailPage(hotel: hotel);
        },
      },
    );
  }
}
