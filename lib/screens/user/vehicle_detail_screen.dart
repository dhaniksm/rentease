import 'package:flutter/material.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';
import 'package:rentease/screens/user/rental_checkout_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  static const routeName = '/vehicle-detail';

  const VehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 376,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.maroon,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(34),
                      bottomRight: Radius.circular(34),
                    ),
                  ),
                  child: vehicle.imageUrl == null || vehicle.imageUrl!.isEmpty
                      ? const Icon(
                          Icons.directions_car_filled,
                          color: AppColors.white,
                          size: 120,
                        )
                      : ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(34),
                            bottomRight: Radius.circular(34),
                          ),
                          child: Image.network(
                            vehicle.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Positioned(
                  top: 20,
                  left: 12,
                  child: IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.maroon.withOpacity(0.8),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 152,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 26,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      '${Formatters.rupiah(vehicle.pricePerDay)}\n/ days',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 18, 8, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        '...',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.vehicleName,
                            style: const TextStyle(
                              color: AppColors.maroon,
                              fontWeight: FontWeight.w900,
                              fontSize: 34,
                            ),
                          ),
                        ),
                        const Text(
                          '4.9',
                          style: TextStyle(
                            color: AppColors.maroon,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Color(0xFFD7B448)),
                      ],
                    ),
                    Text(
                      vehicle.description?.isNotEmpty == true
                          ? vehicle.description!
                          : '${vehicle.brand} ${vehicle.vehicleType}',
                      style: const TextStyle(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(color: AppColors.maroon),
                    const Text(
                      'Detail',
                      style: TextStyle(
                        color: AppColors.maroon,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 18,
                      children: [
                        _DetailBox(text: vehicle.plateNumber),
                        _DetailBox(text: vehicle.vehicleType),
                        _DetailBox(text: vehicle.brand),
                        _DetailBox(text: vehicle.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                width: double.infinity,
                height: 72,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RentalCheckoutScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.maroon,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SEWA',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailBox extends StatelessWidget {
  final String text;

  const _DetailBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 126,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Text(
        text.isEmpty ? '-' : text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
