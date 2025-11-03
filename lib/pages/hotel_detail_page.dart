import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hotel_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';
import '../models/booking_model.dart';
import '../db/hive_manager.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 300,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar penuh
                  Image.network(
                    hotel.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Overlay gradasi bawah
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),

                  // Tombol back & share di atas gambar
                  Positioned(
                    top: 40,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTopButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Nama hotel di bawah gambar
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Text(
                      hotel.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 6,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten utama
          SliverToBoxAdapter(
            child: Padding(
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
                    // ⭐ Rating
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
                    Text(
                      hotel.address.isNotEmpty ? hotel.address : '-',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: const [
                        Icon(Icons.attach_money, color: accentColor, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Harga (USD) / malam',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hotel.priceText.isNotEmpty
                          ? hotel.priceText
                          : 'Tidak tersedia',
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Divider(height: 28),

                    const Text(
                      'Melihat dalam Mata Uang lain : ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          items: _currencyRates.keys
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() => _selectedCurrency = val!);
                          },
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasPrice
                                ? '$formattedPrice / malam'
                                : 'Tidak tersedia',
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

                    const Text(
                      'Pilih Tanggal cek in & cek out : ',
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
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_checkInDate!)
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
                                  ? DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_checkOutDate!)
                                  : 'Pilih Check-out',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Pilih Jam Check-in :',
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
                            : 'Pilih Jam Check-in',
                      ),
                    ),

                    const Divider(height: 28),

                    const Text(
                      'Melihat dari zona Waktu lain : ',
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

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

  Future<void> _bookNow() async {
    if (_checkInDate == null || _checkOutDate == null || _checkInTime == null)
      return;

    final hotel = widget.hotel;
    final booking = BookingModel(
      hotelName: hotel.name,
      platform: 'Booking.com',
      checkInDate: DateFormat('yyyy-MM-dd').format(_checkInDate!),
      finalPrice: hotel.priceText,
      bookingTime: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
    );

    await HiveManager.bookingBox.add(booking);

    // ✅ Notifikasi internal sederhana
    const androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifikasi pemesanan hotel',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF8FA31E),
      styleInformation: BigTextStyleInformation(
        'Booking sukses!',
        contentTitle: '✅ Booking Sukses!',
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
      ),
    );

    const notifDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '✅ Booking Sukses!',
      'Hotel ${hotel.name} berhasil dipesan!',
      notifDetails,
      payload: 'hotel_${hotel.name}',
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/hotel_search');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Booking sukses!'),
        backgroundColor: const Color(0xFF556B2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
