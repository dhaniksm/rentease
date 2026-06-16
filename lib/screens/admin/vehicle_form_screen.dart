import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/primary_button.dart';

class VehicleFormScreen extends StatefulWidget {
  static const routeName = '/vehicle-form';

  const VehicleFormScreen({super.key});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final plateController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final capacityController = TextEditingController();

  String vehicleType = 'MOTOR';
  String status = 'available';
  String transmission = 'Otomatis';
  File? selectedImage;
  bool isLoading = false;
  VehicleModel? editedVehicle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final argument = ModalRoute.of(context)?.settings.arguments;
    if (argument is VehicleModel && editedVehicle == null) {
      editedVehicle = argument;
      nameController.text = argument.vehicleName;
      brandController.text = argument.brand;
      plateController.text = argument.plateNumber;
      priceController.text = argument.pricePerDay.toString();
      capacityController.text = argument.capacity.toString();
      descriptionController.text = argument.description ?? '';
      vehicleType = argument.vehicleType.toUpperCase();
      if (!['MOTOR', 'MOBIL'].contains(vehicleType)) {
        vehicleType = 'MOTOR';
      }

      status = argument.status.toLowerCase();
      if (!['available', 'rented', 'maintenance'].contains(status)) {
        status = 'available';
      }

      transmission = argument.transmission ?? 'Otomatis';
      if (!['Manual', 'Otomatis'].contains(transmission)) {
        transmission = 'Otomatis';
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    plateController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    capacityController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> saveVehicle() async {
    if (nameController.text.trim().isEmpty ||
        brandController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Merk kendaraan wajib diisi')),
      );
      return;
    }

    final price = int.tryParse(priceController.text.replaceAll('.', '')) ?? 0;
    final capacity = int.tryParse(capacityController.text) ?? 4;

    final vehicle = VehicleModel(
      id: editedVehicle?.id ?? '',
      vehicleName: nameController.text.trim(),
      brand: brandController.text.trim(),
      vehicleType: vehicleType.toLowerCase(),
      plateNumber: plateController.text.trim(),
      pricePerDay: price,
      status: status,
      imageUrl: editedVehicle?.imageUrl,
      description: descriptionController.text.trim(),
      transmission: transmission,
      capacity: capacity,
      rating: editedVehicle?.rating ?? 5.0,
    );

    setState(() => isLoading = true);

    try {
      if (editedVehicle == null) {
        await context.read<VehicleProvider>().addVehicle(
          vehicle,
          selectedImage,
        );
      } else {
        await context.read<VehicleProvider>().updateVehicle(
          vehicle,
          selectedImage,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editedVehicle != null;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: Stack(
        children: [
          // IMAGE PICKER HEADER
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.4,
            child: GestureDetector(
              onTap: pickImage,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (selectedImage != null)
                    Image.file(selectedImage!, fit: BoxFit.cover)
                  else if (editedVehicle?.imageUrl != null &&
                      editedVehicle!.imageUrl!.isNotEmpty)
                    Image.network(editedVehicle!.imageUrl!, fit: BoxFit.cover)
                  else
                    Container(
                      color: AppColors.maroon,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white54,
                              size: 64,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap untuk tambah foto',
                              style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Gradient Overlay so back button is visible
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
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
                ],
              ),
            ),
          ),

          // BACK BUTTON & TITLE
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    isEdit ? 'Edit Kendaraan' : 'Tambah Kendaraan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // WHITE BOTTOM SHEET FORM
          Positioned(
            top: screenHeight * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Informasi Utama'),
                      _buildInputGroup(
                        label: 'Nama Kendaraan',
                        icon: Icons.directions_car_outlined,
                        controller: nameController,
                        hint: 'Contoh: Avanza Veloz',
                      ),
                      _buildInputGroup(
                        label: 'Merk',
                        icon: Icons.branding_watermark_outlined,
                        controller: brandController,
                        hint: 'Contoh: Toyota',
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Detail Tipe & Harga'),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownGroup(
                              label: 'Jenis',
                              icon: Icons.category_outlined,
                              value: vehicleType,
                              items: ['MOTOR', 'MOBIL'],
                              onChanged: (val) =>
                                  setState(() => vehicleType = val ?? 'MOTOR'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownGroup(
                              label: 'Status',
                              icon: Icons.info_outline,
                              value: status,
                              items: ['available', 'rented', 'maintenance'],
                              displayItems: ['Tersedia', 'Disewa', 'Perbaikan'],
                              onChanged: (val) =>
                                  setState(() => status = val ?? 'available'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputGroup(
                        label: 'Harga Peminjaman (per hari)',
                        icon: Icons.attach_money,
                        controller: priceController,
                        hint: 'Contoh: 300000',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputGroup(
                              label: 'Kapasitas (Orang)',
                              icon: Icons.people_outline,
                              controller: capacityController,
                              hint: 'Contoh: 4',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownGroup(
                              label: 'Transmisi',
                              icon: Icons.settings_outlined,
                              value: transmission,
                              items: ['Manual', 'Otomatis'],
                              onChanged: (val) =>
                                  setState(() => transmission = val ?? 'Otomatis'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      _buildSectionTitle('Identitas Kendaraan'),
                      _buildInputGroup(
                        label: 'Plat Nomor',
                        icon: Icons.pin_outlined,
                        controller: plateController,
                        hint: 'Contoh: B 1234 ABC',
                      ),
                      _buildInputGroup(
                        label: 'Deskripsi Tambahan',
                        icon: Icons.description_outlined,
                        controller: descriptionController,
                        hint: 'Warna, tahun pembuatan, dll...',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH KENDARAAN',
                        isLoading: isLoading,
                        onPressed: saveVehicle,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.maroon,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputGroup({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.maroon.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.maroon.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.maroon.withValues(alpha: 0.1),
              ),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: const TextStyle(
                color: AppColors.maroon,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: AppColors.maroon.withValues(alpha: 0.3),
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: maxLines == 1
                    ? Icon(
                        icon,
                        color: AppColors.maroon.withValues(alpha: 0.5),
                        size: 20,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 16 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownGroup({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    List<String>? displayItems,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.maroon.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.maroon.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.maroon.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.maroon.withValues(alpha: 0.5),
              ),
              style: const TextStyle(
                color: AppColors.maroon,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              items: List.generate(items.length, (index) {
                return DropdownMenuItem(
                  value: items[index],
                  child: Text(
                    displayItems != null ? displayItems[index] : items[index],
                  ),
                );
              }),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
