import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // plugin notifikasi global (flutterLocalNotificationsPlugin)
import '../models/booking_model.dart';
import '../db/hive_manager.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  // 🎨 Palette
  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color lightGreen = Color(0xFFC6D870);
  static const Color softCream = Color(0xFFEFF5D2);

  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay? _checkInTime;

  String _selectedCurrency = 'USD';
  final Map<String, double> _currencyRates = const {
    'USD': 1.0,
    'IDR': 15500.0,
    'EUR': 0.93,
    'JPY': 151.4,
  };

  @override
  void initState() {
    super.initState();
    // timezone harus di-init sekali
    tzdata.initializeTimeZones();
  }

  // 💱 Konversi USD -> mata uang terpilih
  double _convertToSelectedCurrency(double usdPrice) {
    final rate = _currencyRates[_selectedCurrency] ?? 1.0;
    return usdPrice * rate;
  }

  // 💱 Format tampilan mata uang
  String _formatCurrency(double value) {
    if (_selectedCurrency == 'IDR') {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }
    // default 2 desimal
    return '$_selectedCurrency ${value.toStringAsFixed(2)}';
  }

  // Gabungkan tanggal + jam
  DateTime _combineDateTime(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  // ⏰ Konversi zona waktu
  String _convertTimeZone(DateTime dateTime, String locationName) {
    final loc = tz.getLocation(locationName);
    final tzTime = tz.TZDateTime.from(dateTime, loc);
    return DateFormat('yyyy-MM-dd HH:mm').format(tzTime);
  }

  // 📅 Pilih tanggal check-in
  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Check-in',
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        // pastikan check-out tidak lebih awal dari check-in
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  // 📅 Pilih tanggal check-out
  Future<void> _selectCheckOutDate() async {
    final first = _checkInDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? first.add(const Duration(days: 1)),
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Check-out',
    );
    if (picked != null) {
      setState(() => _checkOutDate = picked);
    }
  }

  // ⏰ Pilih jam check-in
  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime ?? TimeOfDay.now(),
      helpText: 'Pilih Jam Check-in',
    );
    if (picked != null) {
      setState(() => _checkInTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;

    // Perlakuan aman ketika harga tidak tersedia
    final bool hasPrice = hotel.priceUSD > 0;
    final double convertedPrice = hasPrice
        ? _convertToSelectedCurrency(hotel.priceUSD)
        : 0.0;
    final String formattedPrice = hasPrice
        ? _formatCurrency(convertedPrice)
        : 'Tidak tersedia';

    // Enable tombol pesan
    final canBook =
        _checkInDate != null && _checkOutDate != null && _checkInTime != null;

    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          hotel.name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  hotel.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nama
              Text(
                hotel.name,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    hotel.rating.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Alamat
              Text(
                hotel.address.isNotEmpty ? hotel.address : '-',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Harga USD original
              Row(
                children: const [
                  Icon(Icons.attach_money, color: accentColor, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Harga (USD) / malam',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                hotel.priceText.isNotEmpty ? hotel.priceText : 'Tidak tersedia',
                style: const TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Divider(height: 28),

              // 💱 Konversi Mata Uang
              const Text(
                '💰 Konversi Mata Uang',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedCurrency,
                    items: _currencyRates.keys
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _selectedCurrency = val!);
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      hasPrice ? '$formattedPrice / malam' : 'Tidak tersedia',
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),

              const Divider(height: 28),

              // 📅 Pilih tanggal
              const Text(
                '📅 Pilih Tanggal Pemesanan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _selectCheckInDate,
                      icon: const Icon(Icons.login),
                      label: Text(
                        _checkInDate != null
                            ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
                            : 'Pilih Check-in',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _selectCheckOutDate,
                      icon: const Icon(Icons.logout),
                      label: Text(
                        _checkOutDate != null
                            ? DateFormat('yyyy-MM-dd').format(_checkOutDate!)
                            : 'Pilih Check-out',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ⏰ Pilih jam
              const Text(
                '⏰ Pilih Jam Check-in',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _selectCheckInTime,
                label: Text(
                  _checkInTime != null
                      ? _checkInTime!.format(context)
                      : 'Plih Jam Check-in',
                ),
              ),

              const Divider(height: 28),

              // 🌍 Konversi Waktu
              const Text(
                '🌍 Konversi Waktu',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_checkInDate != null && _checkInTime != null) ...[
                _timeRow(
                  'WIB (Jakarta)',
                  _convertTimeZone(
                    _combineDateTime(_checkInDate!, _checkInTime!),
                    'Asia/Jakarta',
                  ),
                ),
                _timeRow(
                  'WITA (Makassar)',
                  _convertTimeZone(
                    _combineDateTime(_checkInDate!, _checkInTime!),
                    'Asia/Makassar',
                  ),
                ),
                _timeRow(
                  'WIT (Jayapura)',
                  _convertTimeZone(
                    _combineDateTime(_checkInDate!, _checkInTime!),
                    'Asia/Jayapura',
                  ),
                ),
                _timeRow(
                  'London',
                  _convertTimeZone(
                    _combineDateTime(_checkInDate!, _checkInTime!),
                    'Europe/London',
                  ),
                ),
              ] else
                const Text(
                  'Pilih tanggal & jam check-in untuk melihat konversi waktu.',
                  style: TextStyle(color: Colors.grey),
                ),

              const SizedBox(height: 24),

              // 🛎️ Pesan sekarang
              Center(
                child: ElevatedButton.icon(
                  onPressed: canBook ? _bookNow : null,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Pesan Sekarang'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canBook ? accentColor : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black26,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper baris waktu
  Widget _timeRow(String label, String timeText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            timeText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Proses booking: simpan ke Hive + notifikasi
  Future<void> _bookNow() async {
    if (_checkInDate == null || _checkOutDate == null || _checkInTime == null)
      return;

    final hotel = widget.hotel;
    final booking = BookingModel(
      hotelName: hotel.name,
      platform: 'Boking.com',
      checkInDate: DateFormat('yyyy-MM-dd').format(_checkInDate!),
      finalPrice: hotel.priceText,
      bookingTime: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    // Simpan ke Hive
    await HiveManager.bookingBox.add(booking);

    // Notifikasi
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifikasi pemesanan hotel',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    const notifDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Pemesanan Berhasil!',
      'Hotel ${hotel.name} telah dipesan.',
      notifDetails,
    );

    if (!mounted) return;
    // Kembali ke halaman search (seperti versi kamu sebelumnya)
    Navigator.of(context).pushReplacementNamed('/hotel_search');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pemesanan berhasil disimpan!')),
    );
  }
}
