import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/hotel_model.dart';
import '../models/booking_model.dart';
import '../main.dart'; 
import '../db/hive_manager.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  DateTime? _checkInDate;
  // Ini adalah nilai harga numerik yang kita konversi dari string harga API
  double _numericPriceIDR = 0; 
  String _priceSymbol = 'IDR';

  final Map<String, double> _currencyRates = {
    'USD': 15500.0, 
    'EUR': 16700.0, 
    'JPY': 105.0,   
  };

  @override
  void initState() {
    super.initState();
    _parsePriceToIDR();
  }

  // Fungsi utilitas untuk mencoba mengkonversi harga string API ke IDR
  void _parsePriceToIDR() {
    // Logika ini mengasumsikan API mengembalikan harga dalam USD (misal: $750)
    String price = widget.hotel.price.replaceAll(RegExp(r'[^0-9.]'), '');
    if (price.isNotEmpty && price.contains('.')) {
      try {
        double priceUSD = double.parse(price);
        // Konversi ke IDR (asumsi harga API dalam USD)
        _numericPriceIDR = priceUSD * _currencyRates['USD']!; 
        _priceSymbol = 'USD'; // Harga dasar dari API adalah USD
      } catch (e) {
        _numericPriceIDR = 5000000; // Fallback jika parsing gagal
        _priceSymbol = 'IDR (Fallback)';
      }
    } else {
        _numericPriceIDDR = 5000000; // Fallback
        _priceSymbol = 'IDR (Fallback)';
    }
  }

  // --- Konversi Mata Uang ---
  String _convertCurrency(double amountIDR, String targetCurrencyCode, double rate) {
    if (rate == 0) return 'N/A';
    final amount = amountIDR / rate;
    final format = NumberFormat.currency(locale: 'en_US', symbol: targetCurrencyCode);
    return format.format(amount);
  }

  // --- Konversi Waktu (WIB, WITA, WIT, London) ---
  String _formatTimezone(String timezoneName) {
    final location = tz.getLocation(timezoneName);
    final now = tz.TZDateTime.now(location);
    return DateFormat('HH:mm:ss').format(now);
  }
  
  // --- Proses Booking dan Notifikasi ---
  void _processBooking() async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in terlebih dahulu!')),
      );
      return;
    }
    
    // 1. Simpan ke Riwayat (Hive)
    final newBooking = BookingModel(
      hotelName: widget.hotel.name,
      platform: 'SerpAPI Source', // Asumsi nama platform
      checkInDate: DateFormat('yyyy-MM-dd').format(_checkInDate!),
      bookingTime: _formatTimezone('Asia/Jakarta'), // Simpan waktu WIB
      finalPrice: NumberFormat.currency(locale: 'id', symbol: 'Rp').format(_numericPriceIDR),
    );
    await HiveManager.bookingBox.add(newBooking);

    // 2. Tampilkan Notifikasi Lokal
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'booking_channel_id', 'Booking Notifications',
      channelDescription: 'Notifikasi konfirmasi pemesanan hotel.',
      importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000, 
      'Pemesanan Berhasil! 🎉',
      '${widget.hotel.name} dibooking untuk tanggal ${DateFormat('dd MMM').format(_checkInDate!)}.', 
      platformChannelSpecifics,
      payload: 'booking_success',
    );

    // 3. Beri feedback ke user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking berhasil! Dicek di Riwayat Pemesanan.')),
    );
  }

  // --- Fungsi Pemilih Tanggal ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)), // Mulai besok
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
      });
    }
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
            _convertCurrency(_numericPriceIDR, code, rate),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail & Booking Hotel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Hotel
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                widget.hotel.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Gambar tidak tersedia')),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(widget.hotel.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(widget.hotel.address, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),

            // --- Konversi Harga Mata Uang ---
            Text(
              '💰 Harga Asli (${_priceSymbol}): ${widget.hotel.price}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)
            ),
            Text(
              'Harga Konversi Dasar (Rp): ${NumberFormat.currency(locale: 'id', symbol: 'Rp').format(_numericPriceIDR)}', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const Divider(),
            _buildCurrencyRow('USD', _currencyRates['USD']!),
            _buildCurrencyRow('EUR', _currencyRates['EUR']!),
            _buildCurrencyRow('JPY', _currencyRates['JPY']!),
            const SizedBox(height: 30),

            // --- Pemilihan Tanggal Check-in ---
            const Text('📅 Tentukan Tanggal Check-in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(_checkInDate == null 
                  ? 'Pilih Tanggal' 
                  : DateFormat('EEEE, dd MMMM yyyy').format(_checkInDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            
            // --- Konversi Waktu (WIB, WITA, WIT, London) ---
            const Text('⏰ Waktu Saat Ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildTimeRow('WIB (Jakarta)', 'Asia/Jakarta'),
            _buildTimeRow('WITA (Makassar)', 'Asia/Makassar'),
            _buildTimeRow('WIT (Jayapura)', 'Asia/Jayapura'),
            _buildTimeRow('London', 'Europe/London'),
            const SizedBox(height: 30),

            // Tombol Booking (Trigger Notifikasi dan Riwayat)
            Center(
              child: ElevatedButton.icon(
                onPressed: _numericPriceIDR == 0 || _checkInDate == null ? null : _processBooking,
                icon: const Icon(Icons.book_online),
                label: const Text('KONFIRMASI BOOKING'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}