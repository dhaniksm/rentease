import 'package:flutter/material.dart';

class LocationUpdateScreen extends StatelessWidget {
  const LocationUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Lokasi (User)')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lokasi berhasil dikirim!')),
            );
          },
          child: const Text('Kirim Lokasi Saat Ini'),
        ),
      ),
    );
  }
}
