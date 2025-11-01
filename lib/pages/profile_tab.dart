import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'about_us_page.dart';
import '../db/hive_manager.dart';

class ProfileTab extends StatefulWidget {
  final UserModel user;
  const ProfileTab({super.key, required this.user});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String? _username;

  @override
  void initState() {
    super.initState();
    // ✅ Ambil data user dari Hive jika tersedia, untuk menjaga data tetap tersimpan
    final storedUser = HiveManager.userBox.get(widget.user.username);
    if (storedUser != null && storedUser.username.isNotEmpty) {
      _username = storedUser.username;
    } else {
      _username = widget.user.username;
    }
  }

  // ✅ Fungsi Logout aman dari context async
  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return; // Hindari context access setelah dispose
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // ✅ Fungsi Edit Nama Profil + Simpan ke Hive
  Future<void> _editProfile(BuildContext context) async {
    final TextEditingController nameController = TextEditingController(
      text: _username,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _username = newName);

                // ✅ Simpan ke Hive
                final user = HiveManager.userBox.get(widget.user.username);
                if (user != null) {
                  user.username = newName;
                  user.save();
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Avatar default (tanpa upload)
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purpleAccent,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _editProfile(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.purple),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _username ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30),

            // ✅ Tombol Logout aman
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
            const Divider(),

            // ✅ Menu About Us
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
