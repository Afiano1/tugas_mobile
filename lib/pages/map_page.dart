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
  LatLng _userLocation = const LatLng(-7.7956, 110.3695);
  bool _isLoadingLocation = true;
  String _locationStatus = 'Mencari lokasi Anda...';
  final List<Marker> _hotelMarkers = [];

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationStatus = 'Memeriksa izin lokasi...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setLocationStatus('Layanan lokasi dimatikan. Aktifkan untuk lanjut.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationStatus =
            'Lokasi: ${_userLocation.latitude}, ${_userLocation.longitude}';
      });

      await _fetchNearbyHotels();
    } catch (e) {
      _setLocationStatus('Gagal mendapatkan lokasi: $e');
    }
  }

  void _setLocationStatus(String status) {
    setState(() {
      _isLoadingLocation = false;
      _locationStatus = status;
    });
  }

  /// 🔍 Ambil hotel di sekitar lokasi user menggunakan SerpAPI
  Future<void> _fetchNearbyHotels() async {
    final apiKey = dotenv.env['SERPAPI_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('❌ API key SerpAPI tidak ditemukan di .env');
      return;
    }

    final url =
        'https://serpapi.com/search.json?engine=google_hotels&hl=id&q=hotel&ll=${_userLocation.latitude},${_userLocation.longitude}&radius=2000&api_key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final results = data['properties'] as List<dynamic>? ?? [];
        List<Marker> markers = [];

        for (var hotel in results) {
          final gps = hotel['gps_coordinates'];
          if (gps != null) {
            final lat = gps['latitude'];
            final lon = gps['longitude'];
            if (lat != null && lon != null) {
              markers.add(
                Marker(
                  point: LatLng(lat, lon),
                  child: const Icon(
                    Icons.location_city,
                    color: Colors.redAccent,
                    size: 30,
                  ),
                ),
              );
            }
          }
        }

        setState(() => _hotelMarkers.addAll(markers));
      } else {
        debugPrint('Gagal memuat hotel: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error saat memuat hotel: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lokasi Hotel (Peta Aman)')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(center: _userLocation, zoom: 13.0),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
                retinaMode: RetinaMode.isHighDensity(context), // ✅ Fix warning
              ),

              // 🔹 Radius sekitar user
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLocation,
                    color: Colors.blue.withOpacity(0.15),
                    borderStrokeWidth: 2,
                    borderColor: Colors.blueAccent,
                    radius: 500,
                  ),
                ],
              ),

              // 🔹 Marker user dan hotel
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userLocation,
                    child: const Icon(
                      Icons.person_pin_circle,
                      color: Colors.blue,
                      size: 45,
                    ),
                  ),
                  ..._hotelMarkers,
                ],
              ),
            ],
          ),

          // Status lokasi user
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(10),
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
