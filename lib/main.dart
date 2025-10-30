import 'package:flutter/material.dart';
import 'db/hive_manager.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
// FIX 3. Import MainScreen
import '../screen/main_screen.dart';
// FIX 1. Import Timezone
import 'package:timezone/data/latest.dart' as tz;
// FIX 2a. Import Notifikasi
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// FIX 2b. Deklarasi Global Plugin Notifikasi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Fungsi untuk menentukan halaman awal (Session Check)
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
  await HiveManager.init();

  // PENTING: Inisialisasi timezone
  tz.initializeTimeZones(); // FIX: Sekarang 'tz' dikenali

  // PENTING: Inisialisasi Notifikasi Lokal
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings();

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  // FIX: Menggunakan initializationSettings yang sudah didefinisikan
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
    );
  }
}
