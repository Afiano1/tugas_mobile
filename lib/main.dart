import 'package:flutter/material.dart';
import 'db/hive_manager.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

// Fungsi untuk menentukan halaman awal (Session Check)
Future<Widget> _getInitialPage() async {
  // Cek apakah ada user yang sedang login
  final UserModel? user = AuthService.getCurrentUser();
  if (user != null) {
    return HomePage(user: user);
  } else {
    return const LoginPage();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager.init(); // Inisialisasi Hive
  final initialPage = await _getInitialPage(); // Tentukan halaman awal

  runApp(MyApp(initialPage: initialPage));
}

class MyApp extends StatelessWidget {
  final Widget initialPage; // Halaman awal

  const MyApp({super.key, required this.initialPage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hive Login Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: initialPage, // Menampilkan halaman awal yang sudah dicek session-nya
    );
  }
}