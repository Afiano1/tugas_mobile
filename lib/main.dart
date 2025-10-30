import 'package:flutter/material.dart';
import 'db/hive_manager.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';
import '../screen/main_screen.dart';
import 'package:timezone/data/latest.dart' as tz;

// Fungsi untuk menentukan halaman awal (Session Check)
Future<Widget> _getInitialPage() async {
  final UserModel? user = AuthService.getCurrentUser();
  if (user != null) {
    // Memastikan MainScreen terimport dan terpakai
    return MainScreen(user: user); 
  } else {
    return const LoginPage();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init(); 

  // PENTING: Inisialisasi timezone, menggunakan prefix 'tz' dari import
  tz.initializeTimeZones(); // <-- FIX: Menggunakan 'tz' prefix

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

