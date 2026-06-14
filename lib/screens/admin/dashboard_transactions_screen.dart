import 'package:flutter/material.dart';

class DashboardTransactionsScreen extends StatelessWidget {
  const DashboardTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Terbaru (Admin)')),
      body: const Center(
        child: Text('Raw list dari transaksi terbaru hari ini.'),
      ),
    );
  }
}
