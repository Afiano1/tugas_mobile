class HotelModel {
  final String name;
  final String address;
  final String price;
  final String imageUrl;
  final double rating;

  HotelModel({
    required this.name,
    required this.address,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    // Ambil harga (kadang berupa map)
    String priceText = 'Tidak tersedia';
    if (json['rate_per_night'] is String) {
      priceText = json['rate_per_night'];
    } else if (json['rate_per_night'] is Map) {
      priceText = json['rate_per_night']['extracted_low'] ??
          json['rate_per_night']['extracted'] ??
          'Tidak tersedia';
    } else if (json['rate_per_night_lower_bound'] != null) {
      priceText = json['rate_per_night_lower_bound'].toString();
    }

    // Ambil gambar (kadang list of maps)
    String imageUrl = 'https://via.placeholder.com/300x200.png?text=No+Image';
    if (json['images'] != null) {
      if (json['images'] is List && json['images'].isNotEmpty) {
        final firstImage = json['images'][0];
        if (firstImage is String) {
          imageUrl = firstImage;
        } else if (firstImage is Map && firstImage['thumbnail'] != null) {
          imageUrl = firstImage['thumbnail'];
        }
      }
    }

    return HotelModel(
      name: json['name'] ?? 'Tanpa nama',
      address: json['address'] ?? '-',
      price: priceText,
      imageUrl: imageUrl,
      rating: (json['overall_rating'] ?? 0).toDouble(),
    );
  }
}
