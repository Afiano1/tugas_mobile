import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // ✅ Tambahkan ini
import 'db/hive_manager.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/hotel_search_page.dart';
import 'pages/hotel_detail_page.dart';
import 'screen/main_screen.dart';
import 'models/hotel_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ Tambahkan ini

// 🔔 Global notifikasi plugin
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // ✅ Muat variabel lingkungan
  await Hive.initFlutter();
  await HiveManager.init();
  tz.initializeTimeZones();

  // 🔔 Inisialisasi notifikasi lengkap (channel + izin)
  await _initializeNotifications();

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
      title: 'Hive Login Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: initialPage,
      routes: {
        '/hotel_search': (context) => const HotelSearchPage(),
        '/hotel_detail': (context) {
          final hotel =
              ModalRoute.of(context)!.settings.arguments as HotelModel;
          return HotelDetailPage(hotel: hotel);
        },
      },
    );
  }
}
