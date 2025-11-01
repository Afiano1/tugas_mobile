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

  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color lightGreen = Color(0xFFC6D870);
  static const Color softCream = Color(0xFFEFF5D2);

  @override
  void initState() {
    super.initState();
    final storedUser = HiveManager.userBox.get(widget.user.username);
    if (storedUser != null && storedUser.username.isNotEmpty) {
      _username = storedUser.username;
    } else {
      _username = widget.user.username;
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  /// 🔹 Edit profil (email hanya tampil, username bisa diubah)
  Future<void> _editProfile(BuildContext context) async {
    final storedUser = HiveManager.userBox.get(widget.user.username);
    final TextEditingController usernameController = TextEditingController(
      text: _username ?? storedUser?.username ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: softCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email (tidak bisa diubah)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: widget.user.email ?? widget.user.username,
                labelStyle: const TextStyle(color: Colors.grey),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Username (editable)
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Masukkan nama pengguna',
                labelStyle: const TextStyle(color: primaryColor),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: accentColor),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: lightGreen),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newUsername = usernameController.text.trim();
              if (newUsername.isNotEmpty) {
                setState(() => _username = newUsername);

                // ✅ Simpan ke Hive agar username baru tampil juga di Home
                final user = HiveManager.userBox.get(widget.user.username);
                if (user != null) {
                  user.username = newUsername;
                  user.save();
                }
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: accentColor,
                  child: Icon(Icons.person, size: 70, color: Colors.white),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _editProfile(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: accentColor, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// 🔹 Menampilkan Username (editable)
            Text(
              _username ?? widget.user.username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const Divider(height: 30, color: lightGreen, thickness: 1),

            /// 🔹 Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logout(context),
            ),
            const Divider(color: lightGreen),

            /// 🔹 About Us
            ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: const Text(
                'About Us',
                style: TextStyle(color: primaryColor),
              ),
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
