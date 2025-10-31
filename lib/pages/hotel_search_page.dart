import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<HotelModel> _hotels = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _fetchHotels(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse(
      'https://serpapi.com/search?engine=google_hotels&q=$query&api_key=20949c48851c8330357e4897bd7c08811ef4d73cd41b1b9768ff71cf5f05a807',
    );

    try {
      print('Fetching from: $url'); // Debugging
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic>? results = data['search_results'];

        if (results == null || results.isEmpty) {
          setState(() => _errorMessage = 'Tidak ada hotel ditemukan.');
        } else {
          // ✅ Gunakan factory constructor dari HotelModel
          setState(() {
            _hotels = results.map((item) => HotelModel.fromJson(item)).toList();
          });
        }
      } else {
        setState(() => _errorMessage =
            'Gagal memuat hotel. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Hotel (SerpAPI)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Hotel (misal: "Yogyakarta")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _fetchHotels(_searchController.text),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hotel.imageUrl,
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                          ),
                        ),
                        title: Text(
                          hotel.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.address),
                            Text(
                              '⭐ ${hotel.rating.toString()}',
                              style: const TextStyle(color: Colors.orange),
                            ),
                            Text(
                              hotel.price,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/hotel_detail',
                            arguments: hotel,
                          );
                        },
                      ),
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
