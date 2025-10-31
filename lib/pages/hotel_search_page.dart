import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../services/hotel_api_service.dart';
import 'hotel_detail_page.dart'; // Halaman baru yang akan kita buat

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<HotelModel>>? _searchResultFuture;

  // Fungsi untuk memulai pencarian API
  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchResultFuture = HotelApiService.searchHotels(query);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Hotel (SerpAPI)')),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Hotel (misal: "Yogyakarta")',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(_searchController.text),
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          
          // 2. Hasil Pencarian (Daftar Hotel)
          Expanded(
            child: FutureBuilder<List<HotelModel>>(
              future: _searchResultFuture,
              builder: (context, snapshot) {
                // Saat sedang loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // Jika ada error
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                // Jika data berhasil dimuat tapi kosong
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada hotel ditemukan. Silakan cari.'));
                }
                
                // Tampilkan daftar hotel
                final hotels = snapshot.data!;
                return ListView.builder(
                  itemCount: hotels.length,
                  itemBuilder: (context, index) {
                    final hotel = hotels[index];
                    return _buildHotelCard(context, hotel);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk satu kartu hotel
  Widget _buildHotelCard(BuildContext context, HotelModel hotel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigasi ke Halaman Detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelDetailPage(hotel: hotel),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              hotel.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                  Container(height: 180, color: Colors.grey[200], child: Icon(Icons.broken_image)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(hotel.address, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hotel.price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(hotel.rating.toString()),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}