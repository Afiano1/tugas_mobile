import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Menggunakan instance global flutterLocalNotificationsPlugin

class HotelSearchPage extends StatefulWidget {
  const HotelSearchPage({super.key});

  @override
  State<HotelSearchPage> createState() => _HotelSearchPageState();
}

class _HotelSearchPageState extends State<HotelSearchPage> {
  DateTime? _checkInDate;
  // Contoh harga dasar dalam IDR
  final double _priceInIDR = 5000000; 
  // Kurs asumsi (Anda bisa menggunakan API real-time jika mau)
  final Map<String, double> _currencyRates = {
    'USD': 15500.0, // 1 USD = 15500 IDR
    'EUR': 16700.0, // 1 EUR = 16700 IDR
    'JPY': 105.0,   // 1 JPY = 105 IDR
    'AUD': 9800.0,  // Tambahan
  };

  // --- Fungsi Konversi Mata Uang ---
  String _convertCurrency(double amountIDR, String targetCurrencyCode, double rate) {
    if (rate == 0) return 'N/A';
    final amount = amountIDR / rate;
    // Menggunakan NumberFormat untuk format yang rapi
    final format = NumberFormat.currency(locale: 'en_US', symbol: targetCurrencyCode);
    return format.format(amount);
  }

  // --- Fungsi Konversi Waktu ---
  String _formatTimezone(String timezoneName) {
    // Pastikan timezone sudah diinisialisasi di main.dart
    try {
      final location = tz.getLocation(timezoneName);
      final now = tz.TZDateTime.now(location);
      return DateFormat('HH:mm:ss').format(now);
    } catch (e) {
      return 'Error Waktu';
    }
  }

  // --- Fungsi Tampilkan Notifikasi (Trigger Booking) ---
  void _showBookingNotification() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in terlebih dahulu!')),
      );
      return;
    }
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_channel_id', 
      'Booking Notifications',
      channelDescription: 'Notifikasi untuk konfirmasi pemesanan hotel.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID Notifikasi
      'Pemesanan Berhasil! 🎉 (Notifikasi)', // Judul notifikasi
      'Hotel Anda telah berhasil dibooking untuk tanggal ${DateFormat('dd MMMM yyyy').format(_checkInDate!)}.', // Isi notifikasi
      platformChannelSpecifics,
      payload: 'booking_success',
    );

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking berhasil! Notifikasi lokal telah dikirim.')),
    );
  }

  // --- Fungsi Pemilih Tanggal ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
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
      appBar: AppBar(title: const Text('Cek Hotel, Konversi & Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Bagian Konversi Waktu (Sesuai Kriteria) ---
            const Text('⏰ Waktu Saat Ini di Berbagai Zona', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildTimeRow('WIB (Asia/Jakarta)', 'Asia/Jakarta'),
            _buildTimeRow('WITA (Asia/Makassar)', 'Asia/Makassar'),
            _buildTimeRow('WIT (Asia/Jayapura)', 'Asia/Jayapura'),
            _buildTimeRow('London (Europe/London)', 'Europe/London'),
            const SizedBox(height: 30),

            // --- Bagian Konversi Mata Uang (Min. 3 Mata Uang) ---
            Text(
              '💰 Harga Dasar (Contoh): ${NumberFormat.currency(locale: 'id', symbol: 'Rp').format(_priceInIDR)}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const Divider(),
            ..._currencyRates.entries.map((entry) => 
              _buildCurrencyRow(entry.key, entry.value)
            ).toList(),
            const SizedBox(height: 30),


            // --- Bagian Pemilihan Tanggal & Booking (Trigger Notifikasi) ---
            const Text('📅 Tentukan Tanggal Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(_checkInDate == null 
                  ? 'Klik untuk Pilih Tanggal' 
                  : 'Tanggal Terpilih: ${DateFormat('EEEE, dd MMMM yyyy').format(_checkInDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 30),
            
            Center(
              child: ElevatedButton.icon(
                // Tombol akan aktif jika tanggal sudah dipilih
                onPressed: _checkInDate == null ? null : _showBookingNotification,
                icon: const Icon(Icons.book),
                label: const Text('KLIK BOOKING (Trigger Notifikasi)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16)
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
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
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
          Text('Konversi ke $code:'),
          Text(
            _convertCurrency(_priceInIDR, code, rate),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }
}