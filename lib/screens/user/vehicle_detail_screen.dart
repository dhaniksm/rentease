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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // 1. HERO IMAGE BACKGROUND
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.5,
            child: vehicle.imageUrl == null || vehicle.imageUrl!.isEmpty
                ? Container(
                    color: AppColors.maroon.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(Icons.directions_car, size: 100, color: AppColors.maroon),
                    ),
                  )
                : Image.network(
                    vehicle.imageUrl!,
                    fit: BoxFit.cover,
                  ),
          ),
          
          // Gradient Overlay at top for back button
          Positioned(
            top: 0, left: 0, right: 0, height: 120,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),
          ),

          // BACK BUTTON & FAVORITE
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircularButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: () => Navigator.pop(context),
                ),
                _buildCircularButton(
                  icon: Icons.favorite_border,
                  onTap: () {
                    // TODO: Implement Favorite
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Disimpan ke Favorit')),
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. BOTTOM SHEET OVERLAP
          Positioned(
            top: screenHeight * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 100), // padding bottom for floating button
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicle.brand.toUpperCase(),
                                        style: TextStyle(
                                          color: AppColors.maroon.withValues(alpha: 0.6),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vehicle.vehicleName,
                                        style: const TextStyle(
                                          color: AppColors.maroon,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.maroon.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: Color(0xFFD7B448), size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        '4.9',
                                        style: TextStyle(
                                          color: AppColors.maroon.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Description
                            Text(
                              'Tentang Kendaraan',
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              vehicle.description?.isNotEmpty == true
                                  ? vehicle.description!
                                  : 'Nikmati perjalanan nyaman dan aman dengan ${vehicle.brand} ${vehicle.vehicleName}. Kendaraan ini dirawat dengan standar tertinggi untuk memastikan kepuasan Anda.',
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.6),
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Specifications Grid
                            Text(
                              'Spesifikasi',
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SpecItem(
                                  icon: vehicle.vehicleType.toLowerCase() == 'motor' 
                                      ? Icons.two_wheeler 
                                      : Icons.directions_car,
                                  title: 'Tipe',
                                  value: vehicle.vehicleType.toUpperCase(),
                                ),
                                _SpecItem(
                                  icon: Icons.pin_outlined,
                                  title: 'Plat',
                                  value: vehicle.plateNumber,
                                ),
                                _SpecItem(
                                  icon: Icons.speed,
                                  title: 'Transmisi',
                                  value: 'Auto', // Placeholder as not in model
                                ),
                                _SpecItem(
                                  icon: Icons.airline_seat_recline_normal,
                                  title: 'Kursi',
                                  value: vehicle.vehicleType.toLowerCase() == 'motor' ? '2' : '4-6',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. FLOATING BOTTOM BAR (Price & Rent Action)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Harga Sewa',
                          style: TextStyle(
                            color: AppColors.maroon.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              Formatters.rupiah(vehicle.pricePerDay),
                              style: const TextStyle(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              '/hari',
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: vehicle.status.toLowerCase() == 'available' || vehicle.status.toLowerCase() == 'tersedia'
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RentalCheckoutScreen(),
                                settings: RouteSettings(arguments: vehicle),
                              ),
                            );
                          }
                        : null, // Disable if not available
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'SEWA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SpecItem({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: AppColors.maroon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.maroon.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(
            color: AppColors.maroon,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
