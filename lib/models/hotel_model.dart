class HotelModel {
  final String name;
  final String address;
  final String imageUrl;
  final double rating;

  /// String siap tampil (mis: "$85", "Tidak tersedia")
  final String priceText;

  /// Angka murni dalam USD untuk konversi (0 jika tidak ada)
  final double priceUSD;

  HotelModel({
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.rating,
    required this.priceText,
    required this.priceUSD,
  });

  /// Helper: ambil angka dari string seperti "$120" → 120.0
  static double _numFromString(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    // --- Ambil gambar (kadang list of strings atau list of maps) ---
    String image = 'https://via.placeholder.com/300x200.png?text=No+Image';
    final imgs = json['images'];
    if (imgs is List && imgs.isNotEmpty) {
      final first = imgs.first;
      if (first is String) {
        image = first;
      } else if (first is Map && first['thumbnail'] is String) {
        image = first['thumbnail'];
      }
    }

    // --- Ambil rating ---
    final rating = double.tryParse('${json['overall_rating'] ?? 0}') ?? 0.0;

    // --- Ambil harga dari beberapa kemungkinan field ---
    String priceText = 'Tidak tersedia';
    double priceUSD = 0.0;

    final rpn = json['rate_per_night'];
    if (rpn is String) {
      priceText = rpn;
      priceUSD = _numFromString(rpn);
    } else if (rpn is Map<String, dynamic>) {
      // Prioritas extracted_low → extracted_high → extracted
      if (rpn['extracted_low'] is String) {
        priceText = rpn['extracted_low'];
        priceUSD = _numFromString(rpn['extracted_low']);
      } else if (rpn['extracted_high'] is String) {
        priceText = rpn['extracted_high'];
        priceUSD = _numFromString(rpn['extracted_high']);
      } else if (rpn['extracted'] is String) {
        priceText = rpn['extracted'];
        priceUSD = _numFromString(rpn['extracted']);
      }
    }

    // Fallback lain
    if (priceUSD == 0.0) {
      final lower = json['rate_per_night_lower_bound'];
      if (lower != null) {
        priceText = '$lower';
        priceUSD = double.tryParse('$lower') ?? 0.0;
      }
    }

    return HotelModel(
      name: json['name'] ?? 'Tanpa nama',
      address: json['address'] ?? '-',
      imageUrl: image,
      rating: rating,
      priceText: priceText,
      priceUSD: priceUSD,
    );
  }
}
