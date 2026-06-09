import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/widgets/main_app_bar.dart';
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
  final chassisController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  String vehicleType = 'MOTOR';
  String status = 'available';
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
      chassisController.text = argument.chassisNumber;
      priceController.text = argument.pricePerDay.toString();
      descriptionController.text = argument.description ?? '';
      vehicleType = argument.vehicleType.toUpperCase();
      status = argument.status;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    brandController.dispose();
    plateController.dispose();
    chassisController.dispose();
    priceController.dispose();
    descriptionController.dispose();
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
    final price = int.tryParse(priceController.text.replaceAll('.', '')) ?? 0;

    final vehicle = VehicleModel(
      id: editedVehicle?.id ?? '',
      vehicleName: nameController.text.trim(),
      brand: brandController.text.trim(),
      vehicleType: vehicleType.toLowerCase(),
      plateNumber: plateController.text.trim(),
      chassisNumber: chassisController.text.trim(),
      pricePerDay: price,
      status: status,
      imageUrl: editedVehicle?.imageUrl,
      description: descriptionController.text.trim(),
    );

    setState(() => isLoading = true);

    try {
      if (editedVehicle == null) {
        await context.read<VehicleProvider>().addVehicle(vehicle, selectedImage);
      } else {
        await context.read<VehicleProvider>().updateVehicle(vehicle, selectedImage);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = editedVehicle != null;

    return Scaffold(
      appBar: MainAppBar(title: isEdit ? 'Edit Kendaraan' : 'Daftar Kendaraan'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(34, 34, 34, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 262,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.maroon, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      )
                    : editedVehicle?.imageUrl != null && editedVehicle!.imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(editedVehicle!.imageUrl!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.add, color: AppColors.maroon, size: 54),
              ),
            ),
            const SizedBox(height: 18),
            _Label('Nama Kendaraan'),
            _Input(controller: nameController),
            _Label('Merk'),
            _Input(controller: brandController),
            _Label('Plat Nomor'),
            _Input(controller: plateController),
            _Label('Nomor Rangka'),
            _Input(controller: chassisController),
            _Label('Jenis Kendaraan'),
            DropdownButtonFormField<String>(
              initialValue: vehicleType,
              items: const [
                DropdownMenuItem(value: 'MOTOR', child: Text('MOTOR')),
                DropdownMenuItem(value: 'MOBIL', child: Text('MOBIL')),
              ],
              onChanged: (value) => setState(() => vehicleType = value ?? 'MOTOR'),
              decoration: _inputDecoration(),
              style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _Label('Status'),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                DropdownMenuItem(value: 'available', child: Text('available')),
                DropdownMenuItem(value: 'rented', child: Text('rented')),
              ],
              onChanged: (value) => setState(() => status = value ?? 'available'),
              decoration: _inputDecoration(),
              style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            _Label('Harga Peminjaman /hari'),
            _Input(controller: priceController, keyboardType: TextInputType.number),
            _Label('Deskripsi'),
            _Input(controller: descriptionController),
            const SizedBox(height: 14),
            Center(
              child: PrimaryButton(
                text: isEdit ? 'SIMPAN' : 'TAMBAH',
                isLoading: isLoading,
                onPressed: saveVehicle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.maroon, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: AppColors.maroon, width: 2),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 6, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _Input({
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.maroon, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: AppColors.maroon, width: 2),
        ),
      ),
    );
  }
}
