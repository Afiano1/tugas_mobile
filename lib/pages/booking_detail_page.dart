import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import '../models/booking_model.dart';
import '../db/hive_manager.dart';
import '../main.dart'; 

class BookingDetailPage extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailPage({super.key, required this.booking});

  static const Color primaryColor = Color(0xFF556B2F);
  static const Color accentColor = Color(0xFF8FA31E);
  static const Color lightGreen = Color(0xFFC6D870);
  static const Color softCream = Color(0xFFEFF5D2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softCream,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Detail Pemesanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.hotelName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1.2, color: lightGreen),
            const SizedBox(height: 10),
            _infoRow('📅 Check-in', booking.checkInDate),
            _infoRow('💰 Harga', booking.finalPrice),
            _infoRow('⏰ Booking', '${booking.bookingTime} (WIB)'),
            const Spacer(),

            // 🔹 Tombol Check-in
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  // ✅ Minta izin jika belum ada
                  final notifPermission = await Permission.notification
                      .request();
                  final alarmPermission = await Permission.scheduleExactAlarm
                      .request();

                  if (!notifPermission.isGranted ||
                      !alarmPermission.isGranted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('⚠️ Izin notifikasi belum diberikan.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }

                  // ✅ Konfirmasi user
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Konfirmasi Check-in',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                            backgroundColor: accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Ya, Sudah Check-in'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  // ✅ Hapus data dari Hive
                  final box = HiveManager.bookingBox;
                  final key = box.keys.firstWhere(
                    (k) => box.get(k) == booking,
                    orElse: () => null,
                  );
                  if (key != null) await box.delete(key);

                  // =====================================================
                  // 🔔 NOTIFIKASI INTERNAL (langsung muncul)
                  // =====================================================
                  const internalAndroid = AndroidNotificationDetails(
                    'internal_checkin_channel',
                    'Internal Notifications',
                    channelDescription: 'Notifikasi langsung check-in',
                    importance: Importance.max,
                    priority: Priority.high,
                    color: accentColor,
                    styleInformation: BigTextStyleInformation(
                      'Terima kasih banyak! Selamat atas check-in nya 🎉',
                      contentTitle: '✅ Check-in Berhasil!',
                      htmlFormatBigText: true,
                      htmlFormatContentTitle: true,
                    ),
                  );
                  const internalNotif = NotificationDetails(
                    android: internalAndroid,
                  );

                  await flutterLocalNotificationsPlugin.show(
                    0,
                    '✅ Check-in Berhasil!',
                    'Terima kasih banyak! Selamat atas check-in nya 🎉',
                    internalNotif,
                  );

                  // =====================================================
                  // 🔔 NOTIFIKASI EKSTERNAL (1 MENIT KEMUDIAN)
                  // =====================================================
                  tzdata.initializeTimeZones();
                  tz.setLocalLocation(
                    tz.getLocation('Asia/Jakarta'),
                  ); // Lokal saja
                  final scheduleTime = tz.TZDateTime.now(
                    tz.local,
                  ).add(const Duration(minutes: 1));

                  const externalAndroid = AndroidNotificationDetails(
                    'external_checkin_channel',
                    'External Notifications',
                    channelDescription: 'Notifikasi eksternal setelah check-in',
                    importance: Importance.max,
                    priority: Priority.high,
                    color: primaryColor,
                    playSound: true,
                    styleInformation: BigTextStyleInformation(
                      'Terima kasih banyak! Selamat atas check-in nya 🎉',
                      contentTitle: '🌿 Check-in Dikonfirmasi!',
                      htmlFormatBigText: true,
                      htmlFormatContentTitle: true,
                    ),
                  );
                  const externalNotif = NotificationDetails(
                    android: externalAndroid,
                  );

                  await flutterLocalNotificationsPlugin.zonedSchedule(
                    1,
                    '🌿 Check-in Dikonfirmasi!',
                    'Terima kasih banyak! Selamat menikmati libura anda 🎉',
                    scheduleTime,
                    externalNotif,
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                    payload: 'checkin_${booking.hotelName}',
                  );

                  // =====================================================
                  // ✅ SnackBar sederhana
                  // =====================================================
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          '✅ Terima kasih banyak! Selamat Menikmati Liburan anda 🎉',
                        ),
                        backgroundColor: primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Check-in Telah Dilakukan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 3,
                  shadowColor: primaryColor.withOpacity(0.3),
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
