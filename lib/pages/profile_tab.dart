import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'about_us_page.dart';

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
    _username = widget.user.username;
  }

  // Fungsi Logout
  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // Fungsi Edit Nama Profil
  void _editProfile(BuildContext context) async {
    final TextEditingController nameController =
        TextEditingController(text: _username);

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
              setState(() {
                _username = nameController.text;
              });
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
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto profil diganti ikon orang
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purpleAccent,
                  child: Icon(
                    Icons.person,
                    size: 70,
                    color: Colors.white,
                  ),
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
            const Divider(),

            // About Us
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
