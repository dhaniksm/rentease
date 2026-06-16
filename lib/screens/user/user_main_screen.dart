import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentease/screens/user/riwayat_user_screen.dart';
import 'package:rentease/screens/user/pengembalian_user_screen.dart';
import 'package:rentease/screens/user/user_dashboard_screen.dart';
import 'package:rentease/screens/user/user_payment_screen.dart';
import 'package:rentease/screens/admin/vehicle_screen.dart';
import 'package:rentease/screens/user/profile_screen.dart';
import 'package:rentease/screens/user/favorite_user_screen.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/services/location_api_service.dart';

class UserMainScreen extends StatefulWidget {
  static const routeName = '/user-main';
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;
  Timer? _locationUpdateTimer;

  late final List<Widget> _screens = [
    UserDashboardScreen(
      onNavigateToVehicle: () {
        setState(() {
          _selectedIndex = 1; // Tab Kendaraan
        });
      },
    ),
    const VehicleScreen(),
    const PengembalianUserScreen(),
    const UserPaymentScreen(),
    const RiwayatUserScreen(),
    const FavoriteUserScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startLocationService();
  }

  Future<void> _startLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied');
      return;
    }

    // Every 1 minute, check active rentals and send location
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        final rentalProvider = context.read<RentalProvider>();
        final rawRentals = rentalProvider.rawRentals;
        
        // Find if user has any active rental
        final activeRental = rawRentals.firstWhere(
          (r) => (r['status'] ?? r['rental_status']) == 'active',
          orElse: () => null,
        );

        if (activeRental != null) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final rentalId = activeRental['id'].toString();
          
          await LocationApiService().sendLocation(
            rentalId, 
            position.latitude, 
            position.longitude
          );
          debugPrint('Location updated for active rental: $rentalId');
        }
      } catch (e) {
        debugPrint('Failed to update location: $e');
      }
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
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 10,
        ),
        elevation: 10,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'KENDARAAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental_outlined),
            activeIcon: Icon(Icons.car_rental),
            label: 'PENGEMBALIAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'BAYAR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'RIWAYAT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'FAVORIT',
          ),
        ],
      ),
    );
  }
}
