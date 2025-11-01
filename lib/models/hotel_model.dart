import 'dart:math';

class HotelModel {
  final String name;
  final String address;
  final String imageUrl;
  final double rating;
  final double priceUSD;
  final String priceText;

  HotelModel({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.priceUSD,
    required this.priceText,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    final random = Random();

    final name = (json['name'] ?? json['title'] ?? 'Unknown').toString();

    // ✅ Perbaikan alamat: ambil dari berbagai kemungkinan field
    final address =
        (json['address'] ??
                json['vicinity'] ??
                json['description'] ??
                json['extensions']?['address'] ??
                json['neighborhood'] ??
                json['location'] ??
                json['formatted_address'] ??
                '-')
            .toString();

    final ratingRaw = json['overall_rating'] ?? json['rating'] ?? 0;
    final rating = ratingRaw is num ? ratingRaw.toDouble() : 0.0;

    final imageUrl =
        (json['thumbnail'] ??
                (json['images'] is List && json['images'].isNotEmpty
                    ? json['images'][0]['thumbnail'] ??
                          json['images'][0]['image']
                    : null) ??
                'https://via.placeholder.com/300x200')
            .toString();

    // Harga dan dummy seperti sebelumnya
    double priceUsd = 0.0;
    String priceText = 'Tidak tersedia';

    if (json['rate_per_night'] is Map) {
      final rate =
          json['rate_per_night']['lowest'] ?? json['rate_per_night']['average'];
      if (rate is Map && rate['extracted_value'] != null) {
        priceUsd = (rate['extracted_value'] as num).toDouble();
        priceText = rate['price'] ?? 'USD ${priceUsd.toStringAsFixed(2)}';
      }
    } else if (json['prices'] is List && (json['prices'] as List).isNotEmpty) {
      final first = json['prices'].first as Map;
      final rateStr = (first['rate'] ?? '').toString();
      if (rateStr.isNotEmpty) {
        final match = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(rateStr);
        if (match != null) priceUsd = double.parse(match.group(1)!);
        priceText = rateStr;
      }
    }

    // Dummy harga jika tidak ada dari API
    if (priceUsd == 0.0) {
      double minPrice, maxPrice;
      if (rating >= 4.8) {
        minPrice = 300;
        maxPrice = 600;
      } else if (rating >= 4.5) {
        minPrice = 150;
        maxPrice = 300;
      } else if (rating >= 4.0) {
        minPrice = 80;
        maxPrice = 150;
      } else {
        minPrice = 50;
        maxPrice = 80;
      }
      priceUsd = minPrice + random.nextDouble() * (maxPrice - minPrice);
      priceText = "USD ${priceUsd.toStringAsFixed(2)}";
    }

    return HotelModel(
      name: name,
      address: address,
      imageUrl: imageUrl,
      rating: rating,
      priceUSD: priceUsd,
      priceText: priceText,
    );
  }
}
