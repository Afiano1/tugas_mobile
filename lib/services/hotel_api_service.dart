import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/hotel_model.dart';
import 'api_constants.dart'; // File yang berisi API Key

class HotelApiService {
  
  // Fungsi untuk mencari hotel berdasarkan query
  static Future<List<HotelModel>> searchHotels(String query) async {
    // Membangun URL lengkap
    final url = Uri.parse(
      '$SERPAPI_HOTELS_BASE_URL&q=$query&gl=id&hl=id&api_key=$SERPAPI_KEY'
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Cek apakah 'properties' ada dan merupakan sebuah List
        if (data['properties'] != null && data['properties'] is List) {
          final List properties = data['properties'];
          
          // Ubah setiap item di list JSON menjadi HotelModel
          return properties
              .map((hotelJson) => HotelModel.fromJson(hotelJson))
              .toList();
        } else {
          // Jika 'properties' tidak ada atau formatnya salah
          return [];
        }
      } else {
        // Gagal memuat data dari API
        throw Exception('Gagal memuat hotel. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error jaringan atau lainnya
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}