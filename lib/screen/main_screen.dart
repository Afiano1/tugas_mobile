import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../pages/home_tab.dart'; // Tab Home
import '../pages/profile_tab.dart'; // Tab Profile

class MainScreen extends StatefulWidget {
  final UserModel user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Inisialisasi list of pages/tabs
    _widgetOptions = <Widget>[
      HomeTab(user: widget.user), // Index 0: Tab Home
      ProfileTab(user: widget.user), // Index 1: Tab Profile
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan menampilkan Tab yang dipilih
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          // Tambahkan item lain di sini jika ada menu utama lain
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}