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
    // --- AMBIL GAMBAR ---
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

    // --- AMBIL RATING ---
    final rating = double.tryParse('${json['overall_rating'] ?? 0}') ?? 0.0;

    // --- AMBIL HARGA ---
    String priceText = 'Tidak tersedia';
    double priceUSD = 0.0;

    // 1️⃣ rate_per_night (string atau map)
    final rate = json['rate_per_night'];
    if (rate is String) {
      priceText = rate;
      priceUSD = _numFromString(rate);
    } else if (rate is Map<String, dynamic>) {
      if (rate['extracted_low'] != null) {
        priceText = rate['extracted_low'];
        priceUSD = _numFromString(rate['extracted_low']);
      } else if (rate['extracted_high'] != null) {
        priceText = rate['extracted_high'];
        priceUSD = _numFromString(rate['extracted_high']);
      } else if (rate['extracted'] != null) {
        priceText = rate['extracted'];
        priceUSD = _numFromString(rate['extracted']);
      }
    }

    // 2️⃣ rates[0].rate_price
    if (priceUSD == 0.0 && json['rates'] is List && json['rates'].isNotEmpty) {
      final firstRate = json['rates'][0];
      if (firstRate is Map && firstRate['rate_price'] != null) {
        final priceData = firstRate['rate_price'];
        if (priceData is Map && priceData['extracted_low'] != null) {
          priceText = priceData['extracted_low'];
          priceUSD = _numFromString(priceData['extracted_low']);
        } else if (priceData is Map && priceData['extracted_high'] != null) {
          priceText = priceData['extracted_high'];
          priceUSD = _numFromString(priceData['extracted_high']);
        } else if (priceData is Map && priceData['extracted'] != null) {
          priceText = priceData['extracted'];
          priceUSD = _numFromString(priceData['extracted']);
        }
      }
    }

    // 3️⃣ rate_plan.price
    if (priceUSD == 0.0 && json['rate_plan'] != null) {
      final plan = json['rate_plan'];
      if (plan['price'] != null) {
        final priceData = plan['price'];
        if (priceData is Map && priceData['extracted_low'] != null) {
          priceText = priceData['extracted_low'];
          priceUSD = _numFromString(priceData['extracted_low']);
        } else if (priceData is Map && priceData['extracted'] != null) {
          priceText = priceData['extracted'];
          priceUSD = _numFromString(priceData['extracted']);
        }
      }
    }

    // 4️⃣ prices[]
    if (priceUSD == 0.0 &&
        json['prices'] is List &&
        json['prices'].isNotEmpty) {
      final first = json['prices'][0];
      if (first is String) {
        priceText = first;
        priceUSD = _numFromString(first);
      } else if (first is Map && first['extracted'] != null) {
        priceText = first['extracted'];
        priceUSD = _numFromString(first['extracted']);
      }
    }

    // 5️⃣ rate_per_night_lower_bound
    if (priceUSD == 0.0 && json['rate_per_night_lower_bound'] != null) {
      priceText = '\$${json['rate_per_night_lower_bound']}';
      priceUSD =
          double.tryParse('${json['rate_per_night_lower_bound']}') ?? 0.0;
    }

    // Fallback
    if (priceUSD == 0.0) {
      priceText = 'Tidak tersedia';
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
