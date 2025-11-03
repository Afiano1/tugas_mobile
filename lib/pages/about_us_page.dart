import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

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
                backgroundColor: Colors.grey[300],
                backgroundImage: const AssetImage('assets/images/aku.png'),
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

            // 🔹 Kesan dan Pesan (Statis)
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
            const SizedBox(height: 15),

            // Kesan terhadap Pemrograman Aplikasi Mobile
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: lightGreen.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.emoji_emotions, color: accentColor, size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kesan terhadap Pemrograman Aplikasi Mobile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Mata kuliah ini sangat menyenangkan karena memberikan kesempatan untuk berkreasi dan mengimplementasikan ide secara langsung melalui aplikasi nyata. '
                            'Selain itu, saya merasa lebih memahami bagaimana aplikasi mobile bekerja dan bagaimana desain UI dapat memengaruhi pengalaman pengguna.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Pesan terhadap Mata Kuliah
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              shadowColor: lightGreen.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.message_rounded, color: accentColor, size: 40),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pesan terhadap Mata Kuliah Pemrograman Aplikasi Mobile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Semoga mata kuliah ini terus dikembangkan dengan materi yang semakin up-to-date dan mendukung mahasiswa untuk lebih memahami tren teknologi terkini. '
                            'Terima kasih kepada dosen dan asisten yang telah membimbing dengan sabar selama proses pembelajaran.',
                            textAlign: TextAlign.justify,
                            style: TextStyle(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              '🌿 Terima kasih telah membaca! 🌿',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
