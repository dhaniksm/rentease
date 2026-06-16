import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/models/rental_model.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';
import 'package:rentease/widgets/primary_button.dart';

class RentalCheckoutScreen extends StatefulWidget {
  static const routeName = '/rental-checkout';

  const RentalCheckoutScreen({super.key});

  @override
  State<RentalCheckoutScreen> createState() => _RentalCheckoutScreenState();
}

class _RentalCheckoutScreenState extends State<RentalCheckoutScreen> {
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = false;

  int get days {
    if (startDate == null || endDate == null) return 0;
    final diff = endDate!.difference(startDate!).inDays;
    return diff < 1 ? 1 : diff; // Minimum 1 hari
  }

  double getTotalPrice(double pricePerDay) {
    return pricePerDay * days;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime initialDate = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? startDate ?? DateTime.now());

    final DateTime firstDate = isStart
        ? DateTime.now()
        : (startDate ?? DateTime.now());

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.maroon, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: AppColors.maroon, // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(startDate!)) {
            endDate = startDate; // Reset endDate if it's before new startDate
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _processCheckout(VehicleModel vehicle) async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal mulai dan selesai'),
        ),
      );
      return;
    }

    final user = context.read<ProfileProvider>().profile;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi pengguna tidak valid. Silakan login kembali.'),
        ),
      );
      return;
    }

    if (user.phoneNumber.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda wajib mengisi Nomor Telepon di menu Profil sebelum menyewa.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final rental = RentalModel(
        id: '', // Diisi backend
        vehicleId: vehicle.id,
        userId: user.id,
        startDate: startDate!,
        endDate: endDate!,
        totalPrice: getTotalPrice(vehicle.pricePerDay.toDouble()),
        status: 'pending',
      );

      await context.read<RentalProvider>().addRental(rental);

      if (!mounted) return;
      context.read<VehicleProvider>().loadVehicles();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pemesanan Berhasil Dikonfirmasi!')),
      );
      Navigator.pop(context); // Kembali ke Home atau Vehicle Detail
      Navigator.pop(context); // Kembali dua kali agar langsung ke list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memesan: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ModalRoute.of(context)!.settings.arguments as VehicleModel;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'CHECKOUT',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.maroon,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. VEHICLE SUMMARY CARD
                  Text(
                    'Kendaraan Terpilih',
                    style: TextStyle(
                      color: AppColors.maroon.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maroon.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: AppColors.maroon.withValues(alpha: 0.05),
                            child:
                                vehicle.imageUrl == null ||
                                    vehicle.imageUrl!.isEmpty
                                ? const Icon(
                                    Icons.directions_car,
                                    color: AppColors.maroon,
                                    size: 40,
                                  )
                                : Image.network(
                                    vehicle.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle.brand.toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.maroon.withValues(
                                    alpha: 0.6,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicle.vehicleName,
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${Formatters.rupiah(vehicle.pricePerDay)} /hari',
                                style: const TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. DATE PICKER
                  Text(
                    'Pilih Tanggal',
                    style: TextStyle(
                      color: AppColors.maroon.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateButton(
                          label: 'Mulai',
                          date: startDate,
                          onTap: () => _selectDate(context, true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateButton(
                          label: 'Selesai',
                          date: endDate,
                          onTap: () => _selectDate(context, false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 3. RECEIPT CARD
                  Text(
                    'Rincian Biaya',
                    style: TextStyle(
                      color: AppColors.maroon.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.maroon.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildReceiptRow(
                          'Harga Sewa',
                          '${Formatters.rupiah(vehicle.pricePerDay)} /hari',
                        ),
                        const SizedBox(height: 12),
                        _buildReceiptRow('Durasi', '$days Hari'),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          width: double.infinity,
                          color: AppColors.maroon.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              Formatters.rupiah(
                                getTotalPrice(
                                  vehicle.pricePerDay.toDouble(),
                                ).toInt(),
                              ),
                              style: const TextStyle(
                                color: AppColors.maroon,
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                              ),
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

          // 4. BOTTOM ACTION BAR
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              MediaQuery.of(context).padding.bottom + 16,
            ),
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
            child: PrimaryButton(
              text: 'SEWA SEKARANG',
              isLoading: isLoading,
              onPressed: () => _processCheckout(vehicle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.maroon.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppColors.maroon,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Pilih Tanggal',
                    style: TextStyle(
                      color: date != null
                          ? AppColors.maroon
                          : AppColors.maroon.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.maroon.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
