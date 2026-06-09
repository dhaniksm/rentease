import 'package:flutter/material.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';

class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.maroon, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.maroon, width: 2),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: vehicle.imageUrl == null || vehicle.imageUrl!.isEmpty
                    ? const Icon(Icons.directions_car, color: AppColors.maroon, size: 34)
                    : Image.network(vehicle.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleName.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.maroon,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.brand,
                    style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${Formatters.rupiah(vehicle.pricePerDay)}/hari',
                    style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vehicle.status,
                    style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, color: AppColors.maroon),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: AppColors.maroon),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
