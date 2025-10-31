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

  @override
  void initState() {
    super.initState();
    _fetchHotels("Indonesia"); // tampilkan default
  }

  Future<void> _fetchHotels(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final checkIn = DateTime.now().add(const Duration(days: 1));
    final checkOut = DateTime.now().add(const Duration(days: 2));
    final checkInStr =
        "${checkIn.year}-${checkIn.month.toString().padLeft(2, '0')}-${checkIn.day.toString().padLeft(2, '0')}";
    final checkOutStr =
        "${checkOut.year}-${checkOut.month.toString().padLeft(2, '0')}-${checkOut.day.toString().padLeft(2, '0')}";

    final url = Uri.parse(
      'https://serpapi.com/search.json'
      '?engine=google_hotels'
      '&q=${Uri.encodeComponent(query + " resorts")}'
      '&check_in_date=$checkInStr'
      '&check_out_date=$checkOutStr'
      '&adults=2'
      '&currency=USD'
      '&gl=us'
      '&hl=en'
      '&api_key=20949c48851c8330357e4897bd7c08811ef4d73cd41b1b9768ff71cf5f05a807',
    );

    try {
      final response = await http.get(url);
      print('📡 URL: $url');
      print('📦 BODY: ${response.body.substring(0, 500)}...'); // limit print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results =
            (data['properties'] ?? data['search_results']) as List<dynamic>?;

        if (results == null || results.isEmpty) {
          setState(() => _errorMessage = 'Tidak ada hotel ditemukan.');
        } else {
          setState(() {
            _hotels = results.map((item) => HotelModel.fromJson(item)).toList();
          });
        }
      } else {
        setState(
          () => _errorMessage =
              'Gagal memuat hotel. Code: ${response.statusCode}',
        );
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
                hintText: 'Cari Hotel (misal: "Bali" atau "Jakarta")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    final query = _searchController.text.trim();
                    _fetchHotels(query.isEmpty ? "Indonesia" : query);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (_hotels.isEmpty)
              const Expanded(
                child: Center(child: Text("Belum ada data hotel.")),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            hotel.imageUrl,
                            width: 80,
                            height: 80,
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
                              hotel.priceText,
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
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
