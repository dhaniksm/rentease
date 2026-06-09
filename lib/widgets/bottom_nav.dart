import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor: AppColors.maroon,
      selectedItemColor: AppColors.white,
      unselectedItemColor: AppColors.white,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home, size: 34), label: 'HOME'),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner, size: 34), label: 'SCAN QR'),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined, size: 34), label: 'MAP'),
        BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined, size: 34), label: 'PEMBAYARAN'),
        BottomNavigationBarItem(icon: Icon(Icons.history, size: 34), label: 'RIWAYAT'),
      ],
    );
  }
}
