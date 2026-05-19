import 'package:flutter/material.dart';
import 'package:rentease/screens/vehicle/vehicle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentEase'),
      ),

      body: const VehicleScreen(),
    );
  }
}