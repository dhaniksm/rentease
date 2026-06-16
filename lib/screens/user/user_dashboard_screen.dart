import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/core/supabase_config.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/vehicle_card.dart';
import 'package:rentease/screens/user/profile_screen.dart';
import 'package:rentease/screens/user/vehicle_detail_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToVehicle;

  const UserDashboardScreen({super.key, required this.onNavigateToVehicle});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles();
      final user = supabase.auth.currentUser;
      if (user != null) {
        context.read<RentalProvider>().loadUserRentals(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final rentalProvider = context.watch<RentalProvider>();

    final profile = profileProvider.profile;
    final String fullName = profile?.fullName ?? 'Pengguna';

    // Get up to 1 recommended vehicles
    final recommendedVehicles = vehicleProvider.vehicles.take(1).toList();
    
    // Get up to 3 recent rentals
    final recentRentals = rentalProvider.rentals.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.maroon.withValues(alpha: 0.1),
                      backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                      child: profile?.avatarUrl == null ? const Icon(
                        Icons.person,
                        color: AppColors.maroon,
                        size: 36,
                      ) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang,',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fullName,
                          style: const TextStyle(
                            color: AppColors.maroon,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Banner / Call to Action
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.maroon,
                      AppColors.maroon.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.maroon.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onNavigateToVehicle,
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Siap Berkendara\nHari Ini?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Pesan Sekarang',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.directions_car,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Rekomendasi Kendaraan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi Kendaraan',
                    style: TextStyle(
                      color: AppColors.maroon,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToVehicle,
                    child: const Text('Lihat Semua', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (vehicleProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.maroon))
              else if (recommendedVehicles.isEmpty)
                const Text('Tidak ada kendaraan tersedia.', style: TextStyle(color: Colors.grey))
              else
                Column(
                  children: recommendedVehicles.map((vehicle) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: VehicleCard(
                        vehicle: vehicle,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const VehicleDetailScreen(),
                              settings: RouteSettings(arguments: vehicle),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Penyewaan Terbaru
              const Text(
                'Penyewaan Terbaru',
                style: TextStyle(
                  color: AppColors.maroon,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              if (rentalProvider.isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.maroon))
              else if (recentRentals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, color: Colors.grey.shade400, size: 48),
                        const SizedBox(height: 12),
                        Text('Belum ada riwayat sewa', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: recentRentals.map((rental) {
                    final linkedVehicle = vehicleProvider.vehicles.where((v) => v.id == rental.vehicleId).firstOrNull;
                    final vehicleName = linkedVehicle?.vehicleName ?? 'Kendaraan';
                    final startDate = rental.startDate.toIso8601String().split('T').first;
                    final status = rental.status.toUpperCase();
                    
                    Color statusColor = Colors.grey;
                    if (status == 'PENDING') statusColor = Colors.orange;
                    if (status == 'PAID') statusColor = Colors.green;
                    if (status == 'ACTIVE') statusColor = Colors.blue;
                    if (status == 'COMPLETED') statusColor = AppColors.maroon;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.car_rental, color: AppColors.maroon),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.darkMaroon,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tanggal: $startDate',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
