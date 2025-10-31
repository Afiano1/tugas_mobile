import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'hotel_search_page.dart'; // Sub Menu 1
import 'map_page.dart'; // Sub Menu 2 (LBS)
// import 'platform_page.txt'; // Sub Menu 3 (API/Pencarian)
import 'history_page.dart'; // Sub Menu 4 (Riwayat)

class HomeTab extends StatelessWidget {
  final UserModel user;
  const HomeTab({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // List menu untuk Home
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Cek Hotel & Booking',
        'icon': Icons.apartment,
        'page': HotelSearchPage(),
      },
      {'title': 'Lokasi Hotel (Maps)', 'icon': Icons.map, 'page': MapPage()},
      // {'title': 'Cari Platform Booking', 'icon': Icons.business, 'page': PlatformPage()},
      {
        'title': 'Riwayat Pemesanan',
        'icon': Icons.history,
        'page': HistoryPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello...
            Text(
              'Hello, ${user.username}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Gambar dengan Kutipan
            _buildQuoteCard(),
            const SizedBox(height: 30),

            const Text(
              'Fitur Utama Proyek',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            // 4 Menu Utama dalam Grid
            GridView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Menonaktifkan scroll GridView
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return _buildMenuItemCard(
                  context,
                  menuItems[index]['title'] as String,
                  menuItems[index]['icon'] as IconData,
                  menuItems[index]['page'] as Widget,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Card(
      elevation: 4,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage(
              'assets/hotel_bg.jpg',
            ), // Ganti dengan path gambar Anda
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              '"Travel is the only thing you buy that makes you richer." - Unknown',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
