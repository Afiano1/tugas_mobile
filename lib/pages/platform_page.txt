import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_constants.dart';

class PlatformPage extends StatefulWidget {
  const PlatformPage({super.key});

  @override
  State<PlatformPage> createState() => _PlatformPageState();
}

class _PlatformPageState extends State<PlatformPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _platforms = [];
  bool _isLoading = false;

  // Asumsi: API akan memberikan data platform booking (misalnya dari data hasil pencarian hotel)
  Future<void> _searchPlatforms(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _platforms = [];
    });

    final url = Uri.parse(
      '$SERPAPI_HOTELS_BASE_URL&q=$query&gl=id&hl=id&api_key=$SERPAPI_KEY'
    );
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Asumsi struktur JSON API memiliki array platform di 'platform_results'
        // Karena API Hotels lebih fokus ke hotel, kita akan mencari di data 'offers'
        List<String> foundPlatforms = [];
        
        // Jika ada hotel yang ditemukan, ambil nama platform dari penawaran
        if (data['properties'] != null) {
          final properties = data['properties'] as List;
          for (var prop in properties) {
             if (prop['offers'] != null) {
               for (var offer in prop['offers']) {
                 if (offer['source'] != null) {
                   foundPlatforms.add(offer['source'] as String);
                 }
               }
             }
          }
        }
        
        setState(() {
          _platforms = foundPlatforms.toSet().toList(); // Ambil yang unik
          _isLoading = false;
        });

      } else {
        // Handle error API
        setState(() {
          _isLoading = false;
          _platforms = ['Gagal memuat data. Status: ${response.statusCode}'];
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _platforms = ['Terjadi kesalahan: ${e.toString()}'];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Platform Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Fasilitas Pencarian
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Hotel (misal: "Yogyakarta")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchPlatforms(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _searchPlatforms,
            ),
            const SizedBox(height: 20),
            
            const Text('Platform yang ditemukan:', style: TextStyle(fontWeight: FontWeight.bold)),
            
            // Tampilan Hasil
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : _platforms.isEmpty && !_isLoading
                      ? const Center(child: Text('Masukkan kata kunci untuk mencari platform.'))
                      : ListView.builder(
                          itemCount: _platforms.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_platforms[index]),
                              leading: const Icon(Icons.web),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}