import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

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
  String _selectedCurrency = 'USD';

  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'IDR': 15500.0,
    'EUR': 0.93,
    'JPY': 151.4,
  };

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();
  }

  double _convertToSelectedCurrency(double usdPrice) {
    final rate = _currencyRates[_selectedCurrency] ?? 1.0;
    return usdPrice * rate;
  }

  String _formatCurrency(double value) {
    if (_selectedCurrency == 'IDR') {
      return 'Rp ${value.toStringAsFixed(0)}';
    } else {
      return '$_selectedCurrency ${value.toStringAsFixed(2)}';
    }
  }

  // Menggabungkan tanggal dan jam check-in
  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Fungsi konversi zona waktu otomatis
  String _convertTimeZone(DateTime dateTime, String locationName) {
    final location = tz.getLocation(locationName);
    final tzTime = tz.TZDateTime.from(dateTime, location);
    final formatted = DateFormat('yyyy-MM-dd HH:mm').format(tzTime);
    return formatted;
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _checkInDate = picked);
  }

  Future<void> _selectCheckOutDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: _checkInDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _checkOutDate = picked);
  }

  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _checkInTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final convertedPrice = _convertToSelectedCurrency(hotel.priceUSD);
    final formattedPrice = _formatCurrency(convertedPrice);

    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                hotel.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hotel.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Alamat: ${hotel.address}'),
            Text('⭐ Rating: ${hotel.rating}'),
            Text('Harga (USD): ${hotel.priceText}'),
            const Divider(height: 32),

            // === KONVERSI MATA UANG ===
            const Text('💰 Konversi Mata Uang:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedCurrency,
              items: _currencyRates.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),
            Text(formattedPrice,
                style: const TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)),
            const Divider(height: 32),

            // === PILIH TANGGAL PEMESANAN ===
            const Text('📅 Pilih Tanggal Pemesanan:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _selectCheckInDate,
                  icon: const Icon(Icons.login),
                  label: Text(_checkInDate != null
                      ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
                      : 'Pilih Check-in'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selectCheckOutDate,
                  icon: const Icon(Icons.logout),
                  label: Text(_checkOutDate != null
                      ? DateFormat('yyyy-MM-dd').format(_checkOutDate!)
                      : 'Pilih Check-out'),
                ),
              ],
            ),
            const Divider(height: 32),

            // === JAM CHECK-IN ===
            const Text('⏰ Pilih Jam Check-in:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _selectCheckInTime,
              icon: const Icon(Icons.access_time),
              label: Text(_checkInTime != null
                  ? _checkInTime!.format(context)
                  : 'Pilih Jam'),
            ),
            const SizedBox(height: 16),

            // === KONVERSI ZONA WAKTU OTOMATIS ===
            const Text('🌍 Konversi Waktu:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            if (_checkInDate != null && _checkInTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                      '🕓 WIB (Jakarta): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Jakarta")}'),
                  Text(
                      '🕓 WITA (Makassar): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Makassar")}'),
                  Text(
                      '🕓 WIT (Jayapura): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Jayapura")}'),
                  Text(
                      '🕓 London: ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Europe/London")}'),
                ],
              )
            else
              const Text(
                'Pilih jam check-in terlebih dahulu untuk melihat konversi waktu.',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 24),

            // === TOMBOL PESAN ===
            Center(
              child: ElevatedButton.icon(
                onPressed: (_checkInDate != null &&
                        _checkOutDate != null &&
                        _checkInTime != null)
                    ? () {}
                    : null,
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
