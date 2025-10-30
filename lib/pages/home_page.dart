import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    // Setelah logout, kembali ke LoginPage dan hapus semua rute sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = AuthService.getAllUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Menu Logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ucapan Selamat Datang
            Text('👋 Selamat datang, ${user.username}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text('📋 Semua user terdaftar:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final u = allUsers[index];
                  return ListTile(
                    title: Text(u.username),
                    subtitle: Text('ID: ${u.key ?? 'N/A'}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}