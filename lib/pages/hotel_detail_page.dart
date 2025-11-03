import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/hotel_model.dart';
import '../models/booking_model.dart';
import '../db/hive_manager.dart';
import '../main.dart';
import '../services/auth_service.dart';

class HotelDetailPage extends StatefulWidget {
  final HotelModel hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
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
    tzdata.initializeTimeZones();
  }

  double _convertToSelectedCurrency(double usdPrice) {
    final rate = _currencyRates[_selectedCurrency] ?? 1.0;
    return usdPrice * rate;
  }

  String _formatCurrency(double value) {
    if (_selectedCurrency == 'IDR') {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }
    return '$_selectedCurrency ${value.toStringAsFixed(2)}';
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  String _convertTimeZone(DateTime dateTime, String locationName) {
    final loc = tz.getLocation(locationName);
    final tzTime = tz.TZDateTime.from(dateTime, loc);
    return DateFormat('yyyy-MM-dd HH:mm').format(tzTime);
  }

  Future<void> _selectCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
          _checkOutDate = null;
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final first = _checkInDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate ?? first.add(const Duration(days: 1)),
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _checkOutDate = picked);
  }

  Future<void> _selectCheckInTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _checkInTime ?? TimeOfDay.now(),
      helpText: 'Pilih Jam Check-in',
    );
    if (picked != null) setState(() => _checkInTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final bool hasPrice = hotel.priceUSD > 0;
    final double convertedPrice = hasPrice
        ? _convertToSelectedCurrency(hotel.priceUSD)
        : 0.0;
    final String formattedPrice = hasPrice
        ? _formatCurrency(convertedPrice)
        : 'Tidak tersedia';

    final canBook =
        _checkInDate != null && _checkOutDate != null && _checkInTime != null;

    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          hotel.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                hotel.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hotel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  hotel.rating.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              '💲 Harga (USD) / malam',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              hotel.priceText.isNotEmpty ? hotel.priceText : 'Tidak tersedia',
              style: const TextStyle(
                color: accentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            const Text(
              'Melihat dalam Mata Uang lain :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: _selectedCurrency,
                  items: _currencyRates.keys
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
                const Spacer(),
                Text(
                  hasPrice ? '$formattedPrice / malam' : 'Tidak tersedia',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            const Text(
              'Pilih Tanggal cek in & cek out :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightGreen,
                      foregroundColor: Colors.black,
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
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightGreen,
                      foregroundColor: Colors.black,
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
            const Divider(height: 24),
            const Text(
              'Pilih Jam Check-in :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: _selectCheckInTime,
              icon: const Icon(Icons.access_time),
              label: Text(
                _checkInTime != null
                    ? _checkInTime!.format(context)
                    : 'Pilih Jam Check-in',
              ),
            ),
            const Divider(height: 24),
            const Text(
              'Melihat dari zona waktu lain :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Pilih tanggal & jam check-in untuk melihat konversi waktu.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: canBook ? () => _bookNow(hotel) : null,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeRow(String label, String timeText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 16, color: primaryColor),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            timeText,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _bookNow(HotelModel hotel) async {
    if (_checkInDate == null || _checkOutDate == null || _checkInTime == null)
      return;

    final currentUser = AuthService.getCurrentUser();

    final booking = BookingModel(
      hotelName: hotel.name,
      platform: 'Booking.com',
      checkInDate: DateFormat('yyyy-MM-dd').format(_checkInDate!),
      bookingTime: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      finalPrice: hotel.priceText,
      userEmail: currentUser?.email ?? 'guest',
    );

    await HiveManager.bookingBox.add(booking);

    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifikasi pemesanan hotel',
      importance: Importance.max,
      priority: Priority.high,
      color: accentColor,
      styleInformation: BigTextStyleInformation(
        'Booking sukses!',
        contentTitle: '✅ Booking Sukses!',
      ),
    );

    const notifDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      0,
      '✅ Booking Sukses!',
      'Hotel ${hotel.name} berhasil dipesan!',
      notifDetails,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/hotel_search');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Booking sukses!'),
        backgroundColor: primaryColor,
      ),
    );
  }
}
