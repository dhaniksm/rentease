import 'package:flutter/material.dart';
import 'package:rentease/screens/admin/dashboard_screen.dart';
import 'package:rentease/screens/admin/location_tracker_screen.dart';
import 'package:rentease/screens/admin/admin_payment_screen.dart';
import 'package:rentease/screens/admin/riwayat_admin_screen.dart';
import 'package:rentease/screens/admin/qr_scanner_screen.dart';
import 'package:rentease/screens/admin/vehicle_screen.dart';
import 'package:rentease/utils/app_colors.dart';

class AdminMainScreen extends StatefulWidget {
  static const routeName = '/admin-main';
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(
      onNavigateToHistory: () {
        setState(() {
          _selectedIndex = 5; // Index for RIWAYAT changed to 5 because of KENDARAAN
        });
      },
    ),
    const QrScannerScreen(),
    const VehicleScreen(),
    const LocationTrackerScreen(),
    const AdminPaymentScreen(),
    const RiwayatAdminScreen(),
  ];

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
            icon: Icon(Icons.qr_code_scanner),
            label: 'SCAN QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'KENDARAAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'MAP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(Icons.fact_check),
            label: 'PEMBAYARAN',
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
