import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../db/hive_manager.dart';
import '../models/booking_model.dart';
import 'booking_detail_page.dart'; // jika file ini ada

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: ValueListenableBuilder<Box<BookingModel>>(
        valueListenable: HiveManager.bookingBox.listenable(),
        builder: (context, box, _) {
          final history = box.values.toList().cast<BookingModel>().reversed.toList();

          if (history.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('Belum ada riwayat pemesanan.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const Icon(Icons.hotel, color: Colors.deepPurple),
                  title: Text(item.hotelName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Platform: ${item.platform}'),
                      Text('Tgl Check-in: ${item.checkInDate}'),
                      Text('Harga: ${item.finalPrice}'),
                      Text('Waktu Booking: ${item.bookingTime} (WIB)'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
