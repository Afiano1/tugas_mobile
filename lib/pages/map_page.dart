import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng _userLocation = const LatLng(-7.7956, 110.3695); // Default: Yogyakarta
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi Anda...';

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

    // Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationStatus('Layanan lokasi dinonaktifkan.');
      return;
    }

    // Cek izin lokasi
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

    // Ambil lokasi user
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationStatus =
            'Lokasi Anda: ${_userLocation.latitude}, ${_userLocation.longitude}';
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Hotel (Maps)')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(center: _userLocation, zoom: 13),
            children: [
              // 🌍 Gunakan tile yang bebas blokir
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),

              // 🔹 Tambahkan radius sekitar user
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

              // 📍 Marker lokasi pengguna
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
                ],
              ),
            ],
          ),

          // Status lokasi
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
