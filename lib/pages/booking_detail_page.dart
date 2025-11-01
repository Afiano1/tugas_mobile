import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/booking_model.dart';
import '../db/hive_manager.dart';
import '../main.dart';
import 'package:timezone/timezone.dart' as tz;

class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pemesanan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.hotelName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Divider(),
            _infoRow('🏨 Platform', booking.platform),
            _infoRow('📅 Check-in', booking.checkInDate),
            _infoRow('💰 Harga', booking.finalPrice),
            _infoRow('⏰ Booking', '${booking.bookingTime} (WIB)'),
            const Spacer(),

            // 🔹 Tombol Check-in
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Konfirmasi dulu
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Check-in'),
                      content: const Text(
                        'Apakah Anda yakin telah melakukan check-in di hotel ini?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Ya, Sudah Check-in'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  // 🔹 Hapus dari Hive
                  final box = HiveManager.bookingBox;
                  final key = box.keys.firstWhere(
                    (k) => box.get(k) == booking,
                    orElse: () => null,
                  );
                  if (key != null) await box.delete(key);

                  // 🔹 Jadwalkan notifikasi 30 detik kemudian
                  const androidDetails = AndroidNotificationDetails(
                    'checkin_channel',
                    'Check-in Notifications',
                    channelDescription: 'Notifikasi setelah check-in dilakukan',
                    importance: Importance.max,
                    priority: Priority.high,
                    playSound: true,
                  );
                  const notifDetails = NotificationDetails(
                    android: androidDetails,
                  );

                  await flutterLocalNotificationsPlugin.zonedSchedule(
                    1,
                    'Check-in Berhasil!',
                    'Anda telah melakukan check-in di hotel ${booking.hotelName}. Selamat menikmati masa inap Anda 🏨',
                    tz.TZDateTime.now(
                      tz.local,
                    ).add(const Duration(seconds: 30)),
                    notifDetails,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    androidAllowWhileIdle: true,
                  );

                  // 🔹 Tampilkan snackbar
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Check-in dikonfirmasi! Notifikasi akan muncul dalam 30 detik.',
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Check-in Telah Dilakukan'),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
