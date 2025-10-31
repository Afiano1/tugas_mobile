class HotelModel {
  final String name;
  final String address;
  final String price; // Harga asli (string, misal: "$750")
  final String imageUrl;
  final double rating; // rating hotel (misal: 4.5)

  HotelModel({
    required this.name,
    required this.address,
    required this.price,
    required this.imageUrl,
    required this.rating,
  });

  // Fungsi factory untuk mengubah JSON dari SerpAPI menjadi objek HotelModel
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      name: json['name'] ?? 'Tanpa nama',
      address: json['address'] ?? '-',
      price: json['rate_per_night'] ?? 'Tidak tersedia',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]
          : 'https://via.placeholder.com/300x200.png?text=No+Image',
      rating: (json['overall_rating'] ?? 0).toDouble(),
    );
  }
}
