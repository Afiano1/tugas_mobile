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

    final rating = double.tryParse('${json['overall_rating'] ?? 0}') ?? 0.0;

    // 🔍 1️⃣ Ambil harga dari berbagai kemungkinan struktur data
    String priceText = 'Tidak tersedia';
    double priceUSD = 0.0;

    // Case 1: langsung ada di rate_per_night
    final rate = json['rate_per_night'];
    if (rate is String) {
      priceText = rate;
      priceUSD =
          double.tryParse(rate.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    } else if (rate is Map<String, dynamic>) {
      if (rate['extracted_low'] != null) {
        priceText = rate['extracted_low'];
        priceUSD =
            double.tryParse(
              rate['extracted_low'].replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0;
      } else if (rate['extracted_high'] != null) {
        priceText = rate['extracted_high'];
        priceUSD =
            double.tryParse(
              rate['extracted_high'].replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0;
      }
    }

    // 🔍 2️⃣ Jika tidak ada, cek di rates[0].rate_price
    if (priceUSD == 0.0 && json['rates'] is List && json['rates'].isNotEmpty) {
      final firstRate = json['rates'][0];
      if (firstRate is Map && firstRate['rate_price'] != null) {
        final priceData = firstRate['rate_price'];
        if (priceData is Map && priceData['extracted_low'] != null) {
          priceText = priceData['extracted_low'];
          priceUSD =
              double.tryParse(
                priceData['extracted_low'].replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0.0;
        } else if (priceData is Map && priceData['extracted_high'] != null) {
          priceText = priceData['extracted_high'];
          priceUSD =
              double.tryParse(
                priceData['extracted_high'].replaceAll(RegExp(r'[^0-9.]'), ''),
              ) ??
              0.0;
        }
      }
    }

    // 🔍 3️⃣ Fallback terakhir: rate_per_night_lower_bound
    if (priceUSD == 0.0 && json['rate_per_night_lower_bound'] != null) {
      priceText = '\$${json['rate_per_night_lower_bound']}';
      priceUSD =
          double.tryParse('${json['rate_per_night_lower_bound']}') ?? 0.0;
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
