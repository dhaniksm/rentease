import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/favorite_provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/screens/user/vehicle_detail_screen.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/vehicle_card.dart';

class FavoriteUserScreen extends StatelessWidget {
  const FavoriteUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Kendaraan Favorit',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.maroon),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer2<FavoriteProvider, VehicleProvider>(
        builder: (context, favoriteProvider, vehicleProvider, child) {
          if (favoriteProvider.isLoading || vehicleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.maroon));
          }

          final favoriteIds = favoriteProvider.favoriteVehicleIds;
          final allVehicles = vehicleProvider.vehicles;

          final favoriteVehicles = allVehicles
              .where((v) => favoriteIds.contains(v.id))
              .toList();

          if (favoriteVehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada favorit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan kendaraan ke favorit untuk melihatnya di sini',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.maroon,
            onRefresh: () async {
              await favoriteProvider.loadFavorites();
              await vehicleProvider.loadVehicles();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteVehicles.length,
              itemBuilder: (context, index) {
                final vehicle = favoriteVehicles[index];
                return VehicleCard(
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
