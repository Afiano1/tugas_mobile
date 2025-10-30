import 'package:flutter/material.dart';
import '../db/hive_manager.dart';

class ProfilePage extends StatelessWidget {
  final String username; 
  // Catatan: Ini harusnya usernameKey (lowercase) yang disimpan di session
  const ProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // Mengambil user dari userBox menggunakan username key (lowercase)
    final user = HiveManager.userBox.get(username); 

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('Username: ${user?.username ?? '-'}'),
          // Hapus Country
        ],
      ),
    );
  }
}