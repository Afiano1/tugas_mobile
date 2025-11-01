import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng _userLocation = const LatLng(-7.7956, 110.3695); // Default: Yogyakarta
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi Anda...';
  List<Marker> _hotelMarkers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Memeriksa izin lokasi...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    // ✅ 1. Pastikan layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationStatus('Layanan lokasi dinonaktifkan.');
      return;
    }

    // ✅ 2. Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLocationStatus('Izin lokasi ditolak pengguna.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setLocationStatus('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
      return;
    }

    // ✅ 3. Ambil posisi pengguna
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationStatus = 'Lokasi Anda: ${_userLocation.latitude}, ${_userLocation.longitude}';
      });

      // Setelah lokasi didapat → ambil hotel
      _fetchNearbyHotels();
    } catch (e) {
      _setLocationStatus('Gagal mendapatkan lokasi: $e');
    }
  }

  void _setLocationStatus(String text) {
    setState(() {
      _isLoadingLocation = false;
      _locationStatus = text;
    });
  }

  // ✅ 4. Ambil data hotel dari SerpAPI berdasarkan lokasi pengguna
  Future<void> _fetchNearbyHotels() async {
    final apiKey = dotenv.env['SERPAPI_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('⚠️ SERPAPI_KEY tidak ditemukan di file .env');
      return;
    }

    // ✅ Tambahkan parameter q agar tidak error 400
    final url =
        'https://serpapi.com/search.json?engine=google_hotels&q=hotel+nearby&ll=@${_userLocation.latitude},${_userLocation.longitude},15z&type=lodging&api_key=$apiKey';

    debugPrint('🔍 Memuat hotel dari: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Respons berhasil diterima.');

        if (data['properties'] != null) {
          final hotels = List<Map<String, dynamic>>.from(data['properties']);
          debugPrint('🏨 ${hotels.length} hotel ditemukan.');

          setState(() {
            _hotelMarkers = hotels.map((hotel) {
              final lat = hotel['gps_coordinates']?['latitude'] ?? 0.0;
              final lng = hotel['gps_coordinates']?['longitude'] ?? 0.0;
              final name = hotel['name'] ?? 'Hotel tanpa nama';

              return Marker(
                point: LatLng(lat, lng),
                width: 80,
                height: 80,
                child: Column(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red, size: 35),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }).toList();
          });
        } else {
          debugPrint('⚠️ Tidak ada data hotel di respons.');
        }
      } else {
        debugPrint('❌ Gagal memuat hotel (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Terjadi kesalahan saat memuat hotel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Hotel (Maps)')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(center: _userLocation, zoom: 13),
            children: [
              // 🌍 Gunakan tile bebas blokir & stabil
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.projek_mobile_teori1',
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              // 🔵 Lingkaran lokasi pengguna
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    color: Colors.blue.withOpacity(0.2),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blueAccent,
                    radius: 400,
                  ),
                ],
              ),

              // 📍 Marker pengguna + hotel
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blueAccent,
                      size: 45,
                    ),
                  ),
                  ..._hotelMarkers,
                ],
              ),
            ],
          ),

          // 🪧 Info lokasi
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _locationStatus,
                  style: TextStyle(
                    color: _isLoadingLocation ? Colors.orange : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.deepPurple,
        child: _isLoadingLocation
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.my_location),
      ),
    );
  }
}
