import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';
import 'hotel_search_page.dart';
import 'history_page.dart';

class HomeTab extends StatefulWidget {
  final UserModel user;
  const HomeTab({super.key, required this.user});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _locationName = 'Mendeteksi lokasi...';
  bool _isGettingLocation = false;

  final PageController _pageController = PageController(viewportFraction: 0.85);

  final List<String> _hotelImages = [
    'assets/images/hotel1.jpg',
    'assets/images/hotel2.jpg',
    'assets/images/hotel3.JPG',
    'assets/images/hotel4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 🔹 Ambil lokasi pengguna
  Future<void> _getUserLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationName = 'Layanan lokasi dinonaktifkan';
          _isGettingLocation = false;
        });
        return;
      }

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

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
        _locationName = 'Gagal mendapatkan lokasi';
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF556B2F);
    const accentColor = Color(0xFF8FA31E);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            /// 🔹 Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${widget.user.displayName} 👋",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isGettingLocation
                          ? "Mendeteksi lokasi..."
                          : _locationName,
                      style: const TextStyle(color: accentColor, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _getUserLocation,
                  icon: const Icon(
                    Icons.add_location_alt_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔹 Banner quote
            _buildQuoteCard(),

            const SizedBox(height: 30),

            /// 🔹 Slider hotel
            const Text(
              "Top Rated Hotels ⭐",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            _buildHotelSlider(),

            const SizedBox(height: 30),

            /// 🔹 Fitur utama proyek
            const Text(
              'Fitur Utama Proyek',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const Divider(),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.2,
              children: [
                _buildFeatureCard(
                  Icons.apartment,
                  'Cek Hotel & Booking',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HotelSearchPage()),
                  ),
                ),
                _buildFeatureCard(
                  Icons.history,
                  'Riwayat Pemesanan',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Slider gambar hotel manual (tanpa auto-scroll)
  Widget _buildHotelSlider() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: _hotelImages.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 1.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
                value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
              }
              return Transform.scale(
                scale: value,
                child: _buildHotelImageCard(_hotelImages[index]),
              );
            },
          );
        },
      ),
    );
  }

  /// 🔹 Kartu gambar hotel
  Widget _buildHotelImageCard(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Kartu kutipan
  Widget _buildQuoteCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/hotel.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '"Travel is the only thing you buy that makes you richer."',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Kartu menu utama
  Widget _buildFeatureCard(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF556B2F)),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
