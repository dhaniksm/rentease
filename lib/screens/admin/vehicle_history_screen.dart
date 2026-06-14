import 'package:flutter/material.dart';

class VehicleHistoryScreen extends StatelessWidget {
  const VehicleHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Mobil Ini (Admin)')),
      body: const Center(
        child: Text('Daftar penyewa yang pernah memakai mobil ini.'),
      ),
    );
  }
}
