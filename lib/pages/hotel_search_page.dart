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

  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color softCream = Color(0xFFEFF5D2);

  @override
  void initState() {
    super.initState();
    _fetchHotels("Indonesia"); // default load
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
      '&hl=en'
      '&api_key=20949c48851c8330357e4897bd7c08811ef4d73cd41b1b9768ff71cf5f05a807',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = (data['properties'] ?? data['search_results']) as List?;
        if (results == null || results.isEmpty) {
          setState(() => _errorMessage = 'Tidak ada hotel ditemukan.');
        } else {
          setState(() {
            _hotels = results.map((item) => HotelModel.fromJson(item)).toList();
          });
        }
      } else {
        _errorMessage = 'Gagal memuat data. Code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Cari Hotel',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Hotel (misal: "Bali" atau "Jakarta")',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios,
                        color: accentColor),
                    onPressed: () {
                      final query = _searchController.text.trim();
                      _fetchHotels(query.isEmpty ? "Indonesia" : query);
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage.isNotEmpty)
              Expanded(
                  child: Center(
                      child: Text(_errorMessage,
                          style: const TextStyle(color: Colors.red))))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            hotel.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                        title: Text(
                          hotel.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hotel.address,
                                style: const TextStyle(fontSize: 12)),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.orange, size: 16),
                                Text(' ${hotel.rating.toStringAsFixed(2)}'),
                              ],
                            ),
                            Text(
                              hotel.priceText,
                              style: const TextStyle(
                                  color: accentColor,
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
