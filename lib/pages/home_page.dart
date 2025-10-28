import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class HomePage extends StatelessWidget {
  final UserModel user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final allUsers = AuthService.getAllUsers();

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang, ${user.username}!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Negara: ${user.country}'),
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
                    subtitle: Text('Country: ${u.country}'),
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
