class HotelModel {
  final String name;
  final String address;
  final double rating;
  final String price; // Harga asli (string, misal: "$750")
  final String imageUrl;

  HotelModel({
    required this.name,
    required this.address,
    required this.rating,
    required this.price,
    required this.imageUrl,
  });

  // Fungsi factory untuk mengubah JSON dari SerpAPI menjadi objek HotelModel
  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      name: json['name'] ?? 'Nama Tidak Tersedia',
      address: json['description'] ?? 'Alamat Tidak Tersedia',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      price: json['price'] ?? 'Harga Tidak Tersedia',
      // Mengambil gambar pertama dari list 'images' jika ada
      imageUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0]['thumbnail']
          : 'https://via.placeholder.com/150', // URL gambar default
    );
  }
}