import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/screens/user/vehicle_detail_screen.dart';
import 'package:rentease/screens/admin/vehicle_form_screen.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/main_app_bar.dart';
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
    Future.microtask(() => context.read<VehicleProvider>().loadVehicles());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<VehicleModel> getFilteredVehicles(List<VehicleModel> vehicles) {
    final keyword = searchController.text.toLowerCase();

    return vehicles.where((vehicle) {
      final matchType =
          selectedType == 'SEMUA' ||
          vehicle.vehicleType.toLowerCase() == selectedType.toLowerCase();
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
    final vehicles = getFilteredVehicles(vehicleProvider.vehicles);

    return Scaffold(
      appBar: const MainAppBar(title: 'Daftar Kendaraan'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.maroon,
        foregroundColor: AppColors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const VehicleFormScreen()),
          );
        },
        child: const Icon(Icons.add, size: 34),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Cari',
                prefixIcon: const Icon(Icons.search, color: AppColors.maroon),
                hintStyle: const TextStyle(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.bold,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.maroon,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.maroon,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['SEMUA', 'MOTOR', 'MOBIL'].map((type) {
                final isSelected = selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
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
                    side: const BorderSide(color: AppColors.maroon, width: 2),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 26),
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
                                        builder: (context) => const VehicleDetailScreen(),
                                        settings: RouteSettings(arguments: vehicle),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const VehicleFormScreen(),
                                        settings: RouteSettings(arguments: vehicle),
                                      ),
                                    );
                                  },
                                  onDelete: () => deleteVehicle(vehicle.id),
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
