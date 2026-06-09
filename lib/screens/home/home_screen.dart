import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/screens/home/dashboard_screen.dart';
import 'package:rentease/screens/profile/profile_screen.dart';
import 'package:rentease/screens/vehicle/vehicle_screen.dart';
import 'package:rentease/widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final screens = const [
    DashboardScreen(),
    VehicleScreen(),
    _SimplePage(title: 'Map'),
    _SimplePage(title: 'Pembayaran'),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<VehicleProvider>().loadVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;

  const _SimplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
