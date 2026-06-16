import 'package:flutter/material.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/favorite_provider.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'tersedia':
        return Colors.green.shade600;
      case 'rented':
      case 'disewa':
        return Colors.orange.shade700;
      case 'maintenance':
        return Colors.red.shade700;
      default:
        return AppColors.maroon;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'rented':
        return 'Disewa';
      case 'maintenance':
        return 'Perbaikan';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(vehicle.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TOP SECTION: Hero Image & Status Badge
                SizedBox(
                  height: 180,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image
                      if (vehicle.imageUrl == null || vehicle.imageUrl!.isEmpty)
                        Container(
                          color: AppColors.maroon.withValues(alpha: 0.05),
                          child: const Icon(
                            Icons.directions_car,
                            size: 80,
                            color: AppColors.maroon,
                          ),
                        )
                      else
                        Image.network(vehicle.imageUrl!, fit: BoxFit.cover),

                      // Gradient Overlay for text readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.3),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Favorite Button
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Consumer<FavoriteProvider>(
                          builder: (context, favoriteProvider, child) {
                            final isFav = favoriteProvider.isFavorite(vehicle.id);
                            return GestureDetector(
                              onTap: () {
                                favoriteProvider.toggleFavorite(vehicle.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFav ? 'Dihapus dari Favorit' : 'Disimpan ke Favorit'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.grey,
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Status Badge
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(vehicle.status),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Edit/Delete buttons (if admin)
                      if (onEdit != null && onDelete != null)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Row(
                            children: [
                              _buildAdminButton(
                                icon: Icons.edit,
                                color: Colors.white,
                                bgColor: AppColors.maroon.withValues(
                                  alpha: 0.8,
                                ),
                                onTap: onEdit!,
                              ),
                              const SizedBox(width: 8),
                              _buildAdminButton(
                                icon: Icons.delete,
                                color: Colors.white,
                                bgColor: Colors.red.withValues(alpha: 0.8),
                                onTap: onDelete!,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // BOTTOM SECTION: Details
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Car Name & Brand
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicle.brand.toUpperCase(),
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehicle.vehicleName,
                              style: const TextStyle(
                                color: AppColors.maroon,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  vehicle.vehicleType.toLowerCase() == 'motor'
                                      ? Icons.two_wheeler
                                      : Icons.directions_car,
                                  size: 16,
                                  color: AppColors.maroon.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.vehicleType.toUpperCase(),
                                  style: TextStyle(
                                    color: AppColors.maroon.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle.rating > 0 ? vehicle.rating.toStringAsFixed(1) : 'Baru',
                                  style: TextStyle(
                                    color: AppColors.maroon.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Price & Action Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Mulai dari',
                            style: TextStyle(
                              color: AppColors.maroon.withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                Formatters.rupiah(vehicle.pricePerDay),
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '/hr',
                                style: TextStyle(
                                  color: AppColors.maroon.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
