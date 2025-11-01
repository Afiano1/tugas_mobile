import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../db/hive_manager.dart';
import '../models/booking_model.dart';
import 'booking_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color lightGreen = Color(0xFFC6D870);
  static const Color softCream = Color(0xFFEFF5D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        title: const Text(
          'Riwayat Pemesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<Box<BookingModel>>(
        valueListenable: HiveManager.bookingBox.listenable(),
        builder: (context, box, _) {
          final history = box.values.toList().cast<BookingModel>().reversed.toList();

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 70, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pemesanan.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    decoration: BoxDecoration(
                      color: lightGreen.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: const Icon(Icons.hotel, color: primaryColor, size: 28),
                  ),
                  title: Text(
                    item.hotelName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🗓️ Tgl Check-in: ${item.checkInDate}',
                            style: const TextStyle(fontSize: 13)),
                        Text('💵 Harga: ${item.finalPrice}',
                            style: const TextStyle(fontSize: 13)),
                        Text('🕒 Booking: ${item.bookingTime} (WIB)',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 18, color: accentColor),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailPage(booking: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
