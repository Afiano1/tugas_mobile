import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  DateTime? _checkInDate;
  final double _priceInIDR = 5000000; // Contoh harga (IDR)

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Inisialisasi timezone
  }

  // --- Konversi Mata Uang (Kriteria: min. 3 mata uang) ---
  String _convertCurrency(double amountIDR, String targetCurrencyCode, double rate) {
    final amount = amountIDR / rate;
    final format = NumberFormat.currency(locale: 'en_US', symbol: targetCurrencyCode);
    return format.format(amount);
  }

  // --- Konversi Waktu (Kriteria: WIB, WIT, WITA, London) ---
  String _formatTimezone(String timezoneName) {
    final location = tz.getLocation(timezoneName);
    final now = tz.TZDateTime.now(location);
    return DateFormat('HH:mm:ss').format(now);
  }

  void _showBookingNotification() {
    // TODO: Panggil notifikasi lokal di sini
    // Untuk saat ini, hanya menampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking berhasil! Notifikasi telah dikirim.')),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cek Hotel & Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Konversi Waktu ---
            const Text('⏰ Konversi Waktu Saat Ini', style: TextStyle(fontWeight: FontWeight.bold)),
            _buildTimeRow('WIB (Jakarta)', 'Asia/Jakarta'),
            _buildTimeRow('WITA (Makassar)', 'Asia/Makassar'),
            _buildTimeRow('WIT (Jayapura)', 'Asia/Jayapura'),
            _buildTimeRow('London', 'Europe/London'),
            const Divider(height: 30),

            // --- Konversi Mata Uang ---
            Text('💰 Harga Contoh (IDR): ${NumberFormat.currency(locale: 'id', symbol: 'Rp').format(_priceInIDR)}', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildCurrencyRow('USD', 15500.0), // Kurs asumsi
            _buildCurrencyRow('EUR', 16700.0), // Kurs asumsi
            _buildCurrencyRow('JPY', 105.0), // Kurs asumsi
            const Divider(height: 30),

            // --- Pemilihan Tanggal & Booking (Trigger Notifikasi) ---
            const Text('📅 Pilih Tanggal Check-in', style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              title: Text(_checkInDate == null 
                  ? 'Pilih Tanggal' 
                  : DateFormat('EEEE, dd MMMM yyyy').format(_checkInDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            
            Center(
              child: ElevatedButton.icon(
                onPressed: _checkInDate == null ? null : _showBookingNotification,
                icon: const Icon(Icons.book),
                label: const Text('KLIK BOOKING (Trigger Notifikasi)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  // Helper untuk menampilkan zona waktu
  Widget _buildTimeRow(String label, String timezoneId) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            _formatTimezone(timezoneId),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper untuk menampilkan konversi mata uang
  Widget _buildCurrencyRow(String code, double rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(code),
          Text(
            _convertCurrency(_priceInIDR, code, rate),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}