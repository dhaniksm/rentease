import 'package:flutter/material.dart';

class RentalActionScreen extends StatelessWidget {
  const RentalActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Sewa (Admin)')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Setujui Sewa / Verifikasi Mobil'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Selesaikan / Kembalikan Mobil'),
            ),
          ],
        ),
      ),
    );
  }
}
