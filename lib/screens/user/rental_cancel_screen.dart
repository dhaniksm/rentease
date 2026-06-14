import 'package:flutter/material.dart';

class RentalCancelScreen extends StatelessWidget {
  const RentalCancelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batalkan Sewa (User)')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {},
          child: const Text('Batalkan Pesanan Ini'),
        ),
      ),
    );
  }
}
