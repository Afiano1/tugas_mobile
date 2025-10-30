import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; // Untuk mendapatkan lokasi user (LBS)

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Koordinat default (misalnya, pusat kota yang relevan)
  LatLng _userLocation = const LatLng(-7.7956, 110.3695); 
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi Anda...';

  // Fungsi untuk meminta dan mendapatkan lokasi user saat ini
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Memeriksa izin lokasi...';
    });

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah layanan lokasi aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationStatus('Layanan lokasi dimatikan. Harap aktifkan.');
      return;
    }

    // 2. Cek status izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setLocationStatus('Izin lokasi ditolak oleh pengguna.');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _setLocationStatus('Izin lokasi ditolak permanen. Buka Pengaturan.');
      return;
    } 

    // 3. Ambil lokasi
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationStatus = 'Lokasi saat ini: ${_userLocation.latitude}, ${_userLocation.longitude}';
      });
    } catch (e) {
      _setLocationStatus('Gagal mendapatkan lokasi: ${e.toString()}');
    }
  }
  
  void _setLocationStatus(String status) {
     setState(() {
        _isLoadingLocation = false;
        _locationStatus = status;
      });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Hotel (Maps)')),
      body: Stack(
        children: [
          // Widget Peta
          FlutterMap(
            options: MapOptions(
              center: _userLocation,
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                // Menggunakan OpenStreetMap
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', 
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    // FIX SINTAKS: Menggunakan 'child' untuk Flutter Map v6+
                    child: const Icon( 
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 40.0,
                    ),
                  ),
                  // Anda dapat menambahkan marker hotel lain di sini
                ],
              ),
            ],
          ),
          
          // Status Lokasi
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
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: _isLoadingLocation 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.my_location),
      ),
    );
  }
}