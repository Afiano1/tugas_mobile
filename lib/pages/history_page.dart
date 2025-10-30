import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy riwayat pemesanan
    final List<Map<String, String>> history = [
      {'hotel': 'Rosewood House', 'platform': 'Booking.com', 'date': '2025-10-01'},
      {'hotel': 'Corner Apartment', 'platform': 'Hotels.com', 'date': '2025-09-25'},
      {'hotel': 'Modern House', 'platform': 'Agoda', 'date': '2025-08-15'},
    ];
    
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemesanan')),
      body: history.isEmpty
          ? const Center(child: Text('Belum ada riwayat pemesanan.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.hotel, color: Colors.deepPurple),
                    title: Text(item['hotel']!),
                    subtitle: Text('Platform: ${item['platform']} | Tanggal: ${item['date']}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Detail riwayat
                    },
                  ),
                );
              },
            ),
    );
  }
}