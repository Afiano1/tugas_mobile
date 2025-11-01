import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';
import 'hotel_search_page.dart';
import 'history_page.dart'; // pastikan file ini ada dan berisi class HistoryPage

class HomeTab extends StatefulWidget {
  final UserModel user;
  const HomeTab({super.key, required this.user});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _locationName = 'Mendeteksi lokasi...';
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  /// 🔹 Ambil lokasi pengguna dan ubah ke nama tempat
  Future<void> _getUserLocation() async {
    setState(() => _isGettingLocation = true);

    try {
      // Pastikan layanan lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationName = 'Layanan lokasi dinonaktifkan';
          _isGettingLocation = false;
        });
        return;
      }

      // Cek dan minta izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationName = 'Izin lokasi ditolak';
            _isGettingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationName = 'Izin lokasi ditolak permanen';
          _isGettingLocation = false;
        });
        return;
      }

      // Ambil posisi terkini
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Konversi ke nama kota / kecamatan
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      String finalText = 'Lokasi tidak diketahui';
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final kec = (p.subAdministrativeArea ?? '').trim();
        final kota = (p.locality ?? p.administrativeArea ?? '').trim();
        finalText = "📍 ${kec.isNotEmpty ? kec : kota}";
      }

      setState(() {
        _locationName = finalText;
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Gagal mendapatkan lokasi: $e';
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 Daftar menu utama
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Cek Hotel & Booking',
        'icon': Icons.apartment,
        'page': const HotelSearchPage(),
      },
      {
        'title': 'Riwayat Pemesanan',
        'icon': Icons.history,
        'page': const HistorPage(), // ✅ class sudah diperbaiki di history_page.dart
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade50,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Home Dashboard',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
            Text(
              _isGettingLocation ? 'Mendeteksi lokasi...' : _locationName,
              style: const TextStyle(fontSize: 14, color: Colors.deepPurple),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _getUserLocation,
            icon: const Icon(Icons.my_location),
            tooltip: 'Perbarui Lokasi',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${widget.user.username}!',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildQuoteCard(),
            const SizedBox(height: 30),

            const Text(
              'Fitur Utama Proyek',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return _buildMenuItemCard(
                  context,
                  item['title'] as String,
                  item['icon'] as IconData,
                  item['page'] as Widget,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Kartu kutipan
  Widget _buildQuoteCard() {
    return Card(
      elevation: 4,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/hotel_bg.jpg'),
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

  /// 🔹 Kartu menu utama
  Widget _buildMenuItemCard(
      BuildContext context, String title, IconData icon, Widget page) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
