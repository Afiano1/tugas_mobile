import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart'; // Import global plugin notifikasi
import '../models/booking_model.dart';
import '../db/hive_manager.dart';

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

  /// 🔹 Konversi USD ke mata uang yang dipilih
  double _convertToSelectedCurrency(double usdPrice) {
    final rate = _currencyRates[_selectedCurrency] ?? 1.0;
    return usdPrice * rate;
  }

  /// 🔹 Format tampilan angka mata uang
  String _formatCurrency(double value) {
    if (_selectedCurrency == 'IDR') {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    } else {
      return '$_selectedCurrency ${value.toStringAsFixed(2)}';
    }
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// 🔹 Konversi zona waktu
  String _convertTimeZone(DateTime dateTime, String locationName) {
    final location = tz.getLocation(locationName);
    final tzTime = tz.TZDateTime.from(dateTime, location);
    return DateFormat('yyyy-MM-dd HH:mm').format(tzTime);
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

    // 🔹 Pastikan tidak error bila harga tidak tersedia
    final hasPrice = hotel.priceUSD > 0;
    final convertedPrice = hasPrice
        ? _convertToSelectedCurrency(hotel.priceUSD)
        : 0.0;
    final formattedPrice = hasPrice
        ? _formatCurrency(convertedPrice)
        : 'Tidak tersedia';

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
            Text(
              'Deskripsi: ${hotel.address.isNotEmpty ? hotel.address : "-"}',
            ),
            Text('⭐ Rating: ${hotel.rating.toStringAsFixed(2)}'),
            Text(
              'Harga (USD): ${hotel.priceText.isNotEmpty ? hotel.priceText : "Tidak tersedia"} / malam',
            ),

            const Divider(height: 32),

            // 🔹 Konversi mata uang
            const Text(
              '💰 Konversi Mata Uang:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedCurrency,
              items: _currencyRates.keys
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),
            Text(
              hasPrice ? '$formattedPrice / malam' : 'Tidak tersedia',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(height: 32),

            const Text(
              '📅 Pilih Tanggal Pemesanan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _selectCheckInDate,
                  icon: const Icon(Icons.login),
                  label: Text(
                    _checkInDate != null
                        ? DateFormat('yyyy-MM-dd').format(_checkInDate!)
                        : 'Pilih Check-in',
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _selectCheckOutDate,
                  icon: const Icon(Icons.logout),
                  label: Text(
                    _checkOutDate != null
                        ? DateFormat('yyyy-MM-dd').format(_checkOutDate!)
                        : 'Pilih Check-out',
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            const Text(
              '⏰ Pilih Jam Check-in:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _selectCheckInTime,
              icon: const Icon(Icons.access_time),
              label: Text(
                _checkInTime != null
                    ? _checkInTime!.format(context)
                    : 'Pilih Jam',
              ),
            ),

            const Divider(height: 32),

            const Text(
              '🌍 Konversi Waktu:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_checkInDate != null && _checkInTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🕓 WIB (Jakarta): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Jakarta")}',
                  ),
                  Text(
                    '🕓 WITA (Makassar): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Makassar")}',
                  ),
                  Text(
                    '🕓 WIT (Jayapura): ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Asia/Jayapura")}',
                  ),
                  Text(
                    '🕓 London: ${_convertTimeZone(_combineDateTime(_checkInDate!, _checkInTime!), "Europe/London")}',
                  ),
                ],
              )
            else
              const Text(
                'Pilih jam check-in terlebih dahulu untuk melihat konversi waktu.',
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 24),

            // 🔹 Tombol pemesanan
            Center(
              child: ElevatedButton.icon(
                onPressed:
                    _checkInDate != null &&
                        _checkOutDate != null &&
                        _checkInTime != null
                    ? () async {
                        // 🔹 1. Buat instance BookingModel
                        final booking = BookingModel(
                          hotelName: hotel.name,
                          platform: 'Flutter App',
                          checkInDate: DateFormat(
                            'yyyy-MM-dd',
                          ).format(_checkInDate!),
                          finalPrice: hotel.priceText,
                          bookingTime: DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(DateTime.now()),
                        );

                        // 🔹 2. Simpan ke Hive
                        final box = HiveManager.bookingBox;
                        await box.add(booking);

                        // 🔹 3. Kirim notifikasi
                        const androidDetails = AndroidNotificationDetails(
                          'booking_channel',
                          'Booking Notifications',
                          channelDescription: 'Notifikasi pemesanan hotel',
                          importance: Importance.max,
                          priority: Priority.high,
                          playSound: true,
                        );
                        const notifDetails = NotificationDetails(
                          android: androidDetails,
                        );
                        await flutterLocalNotificationsPlugin.show(
                          0,
                          'Pemesanan Berhasil!',
                          'Hotel ${hotel.name} telah dipesan.',
                          notifDetails,
                        );

                        // 🔹 4. Kembali ke halaman utama
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed('/hotel_search');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pemesanan berhasil disimpan!'),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Pesan Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
