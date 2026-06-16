import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/screens/user/vehicle_detail_screen.dart';
import 'package:rentease/screens/admin/vehicle_form_screen.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/vehicle_card.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {
  final searchController = TextEditingController();
  String selectedType = 'SEMUA';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().loadVehicles();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<VehicleModel> getFilteredVehicles(List<VehicleModel> vehicles) {
    final keyword = searchController.text.trim().toLowerCase();

    return vehicles.where((vehicle) {
      final vType = vehicle.vehicleType.trim().toLowerCase();
      final isMotor = vType == 'motor' || vType == 'motorcycle' || vType == 'sepeda motor';
      final isMobil = vType == 'mobil' || vType == 'car' || vType == 'mpv' || vType == 'hatchback' || vType == 'suv';
      
      bool matchType = false;
      if (selectedType == 'SEMUA') {
        matchType = true;
      } else if (selectedType == 'MOTOR') {
        matchType = isMotor;
      } else if (selectedType == 'MOBIL') {
        matchType = isMobil || (!isMotor && vType != ''); 
      }

      final matchSearch =
          vehicle.vehicleName.toLowerCase().contains(keyword) ||
          vehicle.brand.toLowerCase().contains(keyword);
      return matchType && matchSearch;
    }).toList();
  }

  Future<void> deleteVehicle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan'),
        content: const Text('Yakin ingin menghapus kendaraan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<VehicleProvider>().deleteVehicle(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final isAdmin = profileProvider.profile?.role == 'admin';
    final vehicles = getFilteredVehicles(vehicleProvider.vehicles);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'KENDARAAN',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.maroon,
              foregroundColor: AppColors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VehicleFormScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, size: 28),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari Kendaraan...',
                filled: true,
                fillColor: AppColors.maroon.withValues(alpha: 0.03),
                prefixIcon: const Icon(Icons.search, color: AppColors.maroon),
                hintStyle: TextStyle(
                  color: AppColors.maroon.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['SEMUA', 'MOTOR', 'MOBIL'].map((type) {
                  final isSelected = selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedType = type),
                      selectedColor: AppColors.maroon,
                      backgroundColor: AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.maroon,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.maroon
                              : AppColors.maroon.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: vehicleProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : RefreshIndicator(
                      onRefresh: context.read<VehicleProvider>().loadVehicles,
                      child: vehicles.isEmpty
                          ? const Center(
                              child: Text(
                                'Belum ada kendaraan',
                                style: TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: vehicles.length,
                              itemBuilder: (context, index) {
                                final vehicle = vehicles[index];
                                return VehicleCard(
                                  vehicle: vehicle,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const VehicleDetailScreen(),
                                        settings: RouteSettings(
                                          arguments: vehicle,
                                        ),
                                      ),
                                    );
                                  },
                                  onEdit: isAdmin
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const VehicleFormScreen(),
                                              settings: RouteSettings(
                                                arguments: vehicle,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  onDelete: isAdmin
                                      ? () => deleteVehicle(vehicle.id)
                                      : null,
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
