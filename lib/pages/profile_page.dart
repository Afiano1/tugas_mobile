import 'package:flutter/material.dart';
import '../db/hive_manager.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color softCream = Color(0xFFEFF5D2);

  @override
  Widget build(BuildContext context) {
    final user = HiveManager.userBox.get(username);

    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        title: const Text(
          'Detail Profil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.person, color: accentColor, size: 40),
              const SizedBox(height: 10),
              Text(
                'Username: ${user?.username ?? '-'}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${user?.username ?? '-'}',
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
