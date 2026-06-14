import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentease/screens/user/riwayat_user_screen.dart';
import 'package:rentease/screens/user/pengembalian_user_screen.dart';
import 'package:rentease/screens/admin/vehicle_screen.dart'; // We use VehicleScreen as home for User for now since it lists cars
import 'package:rentease/utils/app_colors.dart';

class UserMainScreen extends StatefulWidget {
  static const routeName = '/user-main';
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;
  Timer? _locationUpdateTimer;

  final List<Widget> _screens = const [
    VehicleScreen(),
    PengembalianUserScreen(),
    RiwayatUserScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate background location update
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      debugPrint('Background Location Update Simulated...');
      // In a real app, we would send the location to LocationProvider here
    });
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.maroon,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 10),
        elevation: 10,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental_outlined),
            activeIcon: Icon(Icons.car_rental),
            label: 'PENGEMBALIAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'RIWAYAT',
          ),
        ],
      ),
    );
  }
}
