import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../pages/home_tab.dart';
import '../pages/profile_tab.dart';

class MainScreen extends StatefulWidget {
  final UserModel user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi halaman
    _widgetOptions = [
      HomeTab(user: widget.user),
      ProfileTab(user: widget.user),
    ];

    // Inisialisasi animasi
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // 🟢 Jalankan animasi awal supaya halaman pertama langsung tampil
    _controller.forward();
  }

  void _onItemTapped(int index) async {
    if (index != _selectedIndex) {
      await _controller.reverse();
      setState(() => _selectedIndex = index);
      await _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF556B2F);
    const backgroundColor = Color(0xFFEFF5D2);

    return Scaffold(
      backgroundColor: backgroundColor,

      // 🔹 Body dengan animasi fade lembut
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _widgetOptions[_selectedIndex],
      ),

      // 🔹 Bottom Navigation Bar yang elegan
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: backgroundColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.grey[600],
          elevation: 0,
          onTap: _onItemTapped,
          selectedFontSize: 13,
          unselectedFontSize: 12,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: _selectedIndex == 0
                    ? Icon(
                        Icons.home_rounded,
                        color: primaryColor,
                        key: const ValueKey('home_selected'),
                      )
                    : Icon(
                        Icons.home_outlined,
                        color: Colors.grey[600],
                        key: const ValueKey('home_unselected'),
                      ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: _selectedIndex == 1
                    ? Icon(
                        Icons.person,
                        color: primaryColor,
                        key: const ValueKey('profile_selected'),
                      )
                    : Icon(
                        Icons.person_outline,
                        color: Colors.grey[600],
                        key: const ValueKey('profile_unselected'),
                      ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
