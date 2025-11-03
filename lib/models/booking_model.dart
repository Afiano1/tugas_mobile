import 'package:hive/hive.dart';

part 'booking_model.g.dart';

@HiveType(typeId: 1)
class BookingModel extends HiveObject {
  @HiveField(0)
  final String hotelName;
  @HiveField(1)
  final String platform;
  @HiveField(2)
  final String checkInDate;
  @HiveField(3)
  final String bookingTime;
  @HiveField(4)
  final String finalPrice;

  // 🆕 Tambahkan ini untuk filter per user
  @HiveField(5)
  final String userEmail;

  BookingModel({
    required this.hotelName,
    required this.platform,
    required this.checkInDate,
    required this.bookingTime,
    required this.finalPrice,
    required this.userEmail,
  });
}
