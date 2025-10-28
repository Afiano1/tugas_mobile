import 'package:flutter/material.dart';
import '../db/hive_manager.dart';
import '../models/user_model.dart';

class ProfilePage extends StatelessWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final data = HiveManager.usersBox.get(email);
    final user = data != null ? UserModel.fromMap(data) : null;

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
          Text('Name: ${user?.name ?? '-'}'),
          Text('Email: ${user?.email ?? '-'}'),
          Text('Country: ${user?.country ?? '-'}'),
          Text('Created: ${user?.createdAt ?? '-'}'),
        ],
      ),
    );
  }
}
