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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terima kasih atas pesan dan kesanmu!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Warna berdasarkan palet yang kamu berikan
    const primaryColor = Color(0xFF556B2F);
    const accentColor = Color(0xFF8FA31E);
    const lightGreen = Color(0xFFC6D870);
    const softCream = Color(0xFFEFF5D2);

    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Foto Pengembang
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: accentColor,
                backgroundImage: AssetImage('assets/images/p.jpg'),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Tentang Pengembang',
              style: TextStyle(
                color: primaryColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aplikasi ini dikembangkan oleh Ghielbrant Ahnaf Pramudya Herlinanto sebagai bagian dari tugas mata kuliah Pemrograman Aplikasi Mobile.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Biodata Card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Biodata Pengembang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(),
                    SizedBox(height: 6),
                    Text('Nama: Ghielbrant Ahnaf Pramudya Herlinanto'),
                    Text('NIM: 124230154'),
                    Text('Kelas: Pemrograman Aplikasi Mobile SI-D'),
                    Text('Alamat: Sumber Balecatur Gamping Sleman'),
                    Text('Asal: Yogyakarta'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Kesan dan Pesan
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kesan dan Pesan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _kesanController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis kesan/pesan kamu...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: lightGreen),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitKesan,
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text('Kirim'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Daftar Kesan
            if (_listKesan.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Kesan dan Pesan Terkirim:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _listKesan.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.comment, color: primaryColor),
                        title: Text(_listKesan[index]),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
