import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class HotelDetailPage extends StatelessWidget {
  final HotelModel hotel;

  const HotelDetailPage({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: Center(
        child: Text('Ini adalah Halaman Detail untuk ${hotel.name}'),
      ),
    );
  }
}