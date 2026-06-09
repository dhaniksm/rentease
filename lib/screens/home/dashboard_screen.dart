import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/utils/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 56, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 214,
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            color: const Color(0xFF151515),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GRAFIK PENYEWAAN DAN PENDAPATAN',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 26),
                Expanded(child: _DummyChart()),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  icon: Icons.pedal_bike,
                  title: 'TOTAL\nBOOKING',
                  value: '16 Unit',
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _StatBox(
                  icon: Icons.pedal_bike,
                  title: 'UNIT\nTERSEDIA',
                  value: '${vehicleProvider.availableVehicles} Unit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SmallStats(
            totalUsers: 8,
            totalVehicles: vehicleProvider.totalVehicles,
            availableVehicles: vehicleProvider.availableVehicles,
            rentedVehicles: vehicleProvider.rentedVehicles,
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Penyewaan Terkini', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
              Text('Lihat Semua', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          const _RentalItem(title: 'SCOOPY 2021 - P 8888 W', name: 'Adel Madura', days: '3 hari'),
          const _RentalItem(title: 'AVANZA 2017 - W 7777 P', name: 'Lovya Cantik', days: '7 hari'),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatBox({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Icon(icon, color: Colors.white, size: 32)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SmallStats extends StatelessWidget {
  final int totalUsers;
  final int totalVehicles;
  final int availableVehicles;
  final int rentedVehicles;

  const _SmallStats({
    required this.totalUsers,
    required this.totalVehicles,
    required this.availableVehicles,
    required this.rentedVehicles,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ChipStat(label: 'User', value: totalUsers),
        _ChipStat(label: 'Kendaraan', value: totalVehicles),
        _ChipStat(label: 'Tersedia', value: availableVehicles),
        _ChipStat(label: 'Dipinjam', value: rentedVehicles),
      ],
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final int value;

  const _ChipStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.maroon),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value', style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
    );
  }
}

class _RentalItem extends StatelessWidget {
  final String title;
  final String name;
  final String days;

  const _RentalItem({required this.title, required this.name, required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.maroon, width: 2),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.maroon, width: 2),
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.w900, fontSize: 16)),
                Text(name, style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
                Text(days, style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Text('Pickup\n21-05-2026', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DummyChart extends StatelessWidget {
  const _DummyChart();

  @override
  Widget build(BuildContext context) {
    final values = [60, 90, 70, 110, 60, 130, 90];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: values
          .map((value) => Container(
                width: 18,
                height: value.toDouble(),
                color: AppColors.maroon,
              ))
          .toList(),
    );
  }
}
