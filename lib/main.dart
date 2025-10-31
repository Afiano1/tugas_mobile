import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'db/hive_manager.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/hotel_search_page.dart';
import 'pages/hotel_detail_page.dart';
import 'screen/main_screen.dart';
import 'models/hotel_model.dart';

// 🔔 Global plugin notifikasi dan navigator key
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
  await Hive.initFlutter();
  await HiveManager.init();
  tz.initializeTimeZones();

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iOS = DarwinInitializationSettings();
  const settings = InitializationSettings(android: android, iOS: iOS);
  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // aksi saat klik notifikasi (optional)
    },
  );

  final initialPage = await _getInitialPage();

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage;

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Hive Login Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: initialPage,
      routes: {
        '/hotel_search': (context) => const HotelSearchPage(),
        '/hotel_detail': (context) {
          final hotel = ModalRoute.of(context)!.settings.arguments as HotelModel;
          return HotelDetailPage(hotel: hotel);
        },
      },
    );
  }
}
