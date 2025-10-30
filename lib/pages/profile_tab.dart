import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart'; // Untuk Logout

class ProfileTab extends StatelessWidget {
  final UserModel user;
  const ProfileTab({super.key, required this.user});

  void _logout(BuildContext context) async {
    await AuthService.logout();
    // Kembali ke LoginPage dan hapus semua route sebelumnya
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Gambar Profil (sesuai kriteria: menu profil (ada gambar))
            const CircleAvatar(
              radius: 50,
              // Ganti dengan gambar user atau default avatar
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'), 
            ),
            const SizedBox(height: 10),
            Text(
              user.username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            // Menu Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
            const Divider(),

            // Kesan dan Pesan
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Kesan dan Pesan'),
              onTap: () {
                // Tampilkan dialog atau navigasi ke halaman Kesan/Pesan
                _showKesanPesan(context);
              },
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void _showKesanPesan(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kesan dan Pesan'),
        content: const Text(
          'Ini adalah tempat untuk menu kesan dan saran mata kuliah Pemrograman Aplikasi Mobile dan Logout (sesuai kriteria).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}