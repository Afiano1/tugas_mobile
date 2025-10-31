import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay? _checkInTime;
  String _selectedZone = 'WIB';
  String _selectedCurrency = 'IDR';

  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'JPY': 150.3,
    'IDR': 15800.0,
  };

  double _parsePriceToUSD(dynamic priceData) {
    if (priceData == null) return 0;

    if (priceData is String) {
      final cleaned = priceData.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }

    if (priceData is Map<String, dynamic>) {
      if (priceData.containsKey('extracted_low')) {
        final cleaned = priceData['extracted_low'].replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0;
      } else if (priceData.containsKey('extracted_high')) {
        final cleaned = priceData['extracted_high'].replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0;
      } else if (priceData.containsKey('rate_per_night_lower_bound')) {
        final cleaned = priceData['rate_per_night_lower_bound'].replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? 0;
      }
    }

    return 0;
  }

  String _convertCurrency(double usd, String target) {
    final converted = usd * _currencyRates[target]!;
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: target == 'IDR' ? 'Rp ' : '$target ',
    );
    return format.format(converted);
  }

  String _convertTimeZone(DateTime date, String zone) {
    switch (zone) {
      case 'WIB':
        return DateFormat('yyyy-MM-dd HH:mm').format(date.toUtc().add(const Duration(hours: 7)));
      case 'WITA':
        return DateFormat('yyyy-MM-dd HH:mm').format(date.toUtc().add(const Duration(hours: 8)));
      case 'WIT':
        return DateFormat('yyyy-MM-dd HH:mm').format(date.toUtc().add(const Duration(hours: 9)));
      case 'London':
        return DateFormat('yyyy-MM-dd HH:mm').format(date.toUtc());
      default:
        return DateFormat('yyyy-MM-dd HH:mm').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
  final baseUSD = hotel.priceUSD; // double aman untuk dihitung


    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar hotel
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                hotel.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),
            const SizedBox(height: 16),

            Text(hotel.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Alamat: ${hotel.address}'),
            Text('⭐ Rating: ${hotel.rating}'),
           Text('Harga (USD): ${hotel.priceText}'),

            const Divider(height: 30),

            // Konversi harga
            const Text('💰 Konversi Mata Uang:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCurrency,
              onChanged: (value) => setState(() => _selectedCurrency = value!),
              items: _currencyRates.keys
                  .map((code) =>
                      DropdownMenuItem(value: code, child: Text(code)))
                  .toList(),
            ),
            Text(
              _convertCurrency(baseUSD, _selectedCurrency),
              style: const TextStyle(
                  color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Divider(height: 30),

            // Tanggal check-in & check-out
            const Text('📅 Pilih Tanggal Pemesanan:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: Text(_checkInDate == null
                      ? 'Pilih Check-in'
                      : DateFormat('yyyy-MM-dd').format(_checkInDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null) {
                      setState(() => _checkInDate = picked);
                    }
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(_checkOutDate == null
                      ? 'Pilih Check-out'
                      : DateFormat('yyyy-MM-dd').format(_checkOutDate!)),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _checkInDate ?? DateTime.now(),
                      firstDate: _checkInDate ?? DateTime.now(),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null) {
                      setState(() => _checkOutDate = picked);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Pilih waktu check-in
            const Text('⏰ Pilih Jam Check-in:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_checkInTime == null
                  ? 'Pilih Jam'
                  : _checkInTime!.format(context)),
              onPressed: () async {
                final picked =
                    await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) {
                  setState(() => _checkInTime = picked);
                }
              },
            ),

            const Divider(height: 30),

            // Pilih zona waktu
            const Text('🌍 Pilih Zona Waktu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedZone,
              onChanged: (value) => setState(() => _selectedZone = value!),
              items: const [
                DropdownMenuItem(value: 'WIB', child: Text('WIB (Jakarta)')),
                DropdownMenuItem(value: 'WITA', child: Text('WITA (Makassar)')),
                DropdownMenuItem(value: 'WIT', child: Text('WIT (Jayapura)')),
                DropdownMenuItem(value: 'London', child: Text('London')),
              ],
            ),

            if (_checkInDate != null && _checkInTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '🕒 Check-in ($_selectedZone): ${_convertTimeZone(DateTime(_checkInDate!.year, _checkInDate!.month, _checkInDate!.day, _checkInTime!.hour, _checkInTime!.minute), _selectedZone)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

            const SizedBox(height: 25),

            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Pesan Sekarang'),
                onPressed: (_checkInDate == null || _checkOutDate == null)
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Pemesanan berhasil disimpan!'),
                            backgroundColor: Colors.green,
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
