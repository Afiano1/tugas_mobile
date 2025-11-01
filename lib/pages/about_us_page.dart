import 'package:flutter/material.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final TextEditingController _kesanController = TextEditingController();
  final List<String> _listKesan = [];

  void _submitKesan() {
    if (_kesanController.text.isNotEmpty) {
      setState(() {
        _listKesan.add(_kesanController.text);
        _kesanController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tentang Pengembang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aplikasi ini dikembangkan oleh gilbran sebagai bagian dari tugas mata kuliah Pemrograman Aplikasi Mobile.',
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Kesan dan Pesan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _kesanController,
              decoration: const InputDecoration(
                labelText: 'Tulis kesan/pesan kamu...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitKesan,
              child: const Text('Kirim'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _listKesan.length,
                itemBuilder: (context, index) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: const Icon(Icons.comment),
                    title: Text(_listKesan[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
