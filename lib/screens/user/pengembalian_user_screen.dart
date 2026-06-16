import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/providers/vehicle_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';

class PengembalianUserScreen extends StatefulWidget {
  const PengembalianUserScreen({super.key});

  @override
  State<PengembalianUserScreen> createState() => _PengembalianUserScreenState();
}

class _PengembalianUserScreenState extends State<PengembalianUserScreen> {
  List<dynamic> activeRentals = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchActiveRentals();
    });
  }

  Future<void> fetchActiveRentals() async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.profile == null) {
      await profileProvider.loadProfile();
    }
    final userId = profileProvider.profile?.id;

    if (userId == null) return;

    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final rentalProvider = context.read<RentalProvider>();
      await rentalProvider.loadUserRentals(userId);

      if (!mounted) return;
      setState(() {
        // Filter only active rentals
        activeRentals = rentalProvider.rawRentals.where((rental) {
          final status = rental['status'] ?? rental['rental_status'] ?? '';
          return status == 'active';
        }).toList();
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleReturnVehicle(String rentalId, String vehicleName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text(
          'Konfirmasi Pengembalian',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengajukan pengembalian untuk $vehicleName?',
          style: TextStyle(color: AppColors.maroon.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Kembalikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    if (!mounted) return;
    try {
      await context.read<RentalProvider>().returnRental(rentalId);

      if (!mounted) return;
      context.read<VehicleProvider>().loadVehicles();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Berhasil mengajukan pengembalian kendaraan!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      fetchActiveRentals();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mengajukan pengembalian: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.maroon,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDateRange(String? startDateStr, int totalDays) {
    if (startDateStr == null) return '';
    try {
      final start = DateTime.parse(startDateStr);
      final end = start.add(Duration(days: totalDays - 1));

      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      final startDay = start.day;
      final endDay = end.day;
      final startMonth = months[start.month - 1];
      final endMonth = months[end.month - 1];
      final startYear = start.year;
      final endYear = end.year;

      if (startYear == endYear) {
        if (startMonth == endMonth) {
          return '$startDay - $endDay $startMonth $startYear';
        } else {
          return '$startDay $startMonth - $endDay $endMonth $startYear';
        }
      } else {
        return '$startDay $startMonth $startYear - $endDay $endMonth $endYear';
      }
    } catch (_) {
      return startDateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PENGEMBALIAN',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchActiveRentals,
              color: AppColors.maroon,
              child: isLoading && activeRentals.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : activeRentals.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.car_rental,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada kendaraan yang perlu dikembalikan.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemCount: activeRentals.length,
                      itemBuilder: (context, index) {
                        final rental = activeRentals[index];
                        final rentalId = rental['id'] ?? '';
                        final vehicle = rental['vehicle'] ?? {};
                        final vName =
                            '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''}'
                                .trim();
                        final plate = vehicle['plate_number'] ?? '-';
                        final imageUrl = vehicle['image_url'];

                        final totalDays =
                            rental['total_days'] ?? rental['durasi_sewa'] ?? 0;
                        final dynamic rawPrice =
                            rental['total_price'] ??
                            rental['total_pembayaran'] ??
                            0;
                        final totalPrice = rawPrice is double
                            ? rawPrice.toInt()
                            : (rawPrice is int ? rawPrice : 0);
                        final startDate =
                            rental['start_date'] ?? rental['waktu_sewa'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.maroon.withValues(alpha: 0.1),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.maroon.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Section
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: AppColors.maroon.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child:
                                            imageUrl != null &&
                                                imageUrl.toString().isNotEmpty
                                            ? Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(
                                                Icons.directions_car,
                                                color: AppColors.maroon,
                                                size: 40,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade600
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade600,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'SEDANG DISEWA',
                                                  style: TextStyle(
                                                    color: Colors.blue.shade600,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            vName.isEmpty
                                                ? 'KENDARAAN'
                                                : vName.toUpperCase(),
                                            style: const TextStyle(
                                              color: AppColors.maroon,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.maroon
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  plate,
                                                  style: const TextStyle(
                                                    color: AppColors.maroon,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
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
                              // Middle Section (Price & Duration)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.maroon.withValues(
                                    alpha: 0.04,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Waktu Sewa ($totalDays Hari)',
                                          style: TextStyle(
                                            color: AppColors.maroon.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDateRange(
                                            startDate,
                                            totalDays,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.maroon,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Total Tagihan',
                                          style: TextStyle(
                                            color: AppColors.maroon.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          Formatters.rupiah(totalPrice),
                                          style: const TextStyle(
                                            color: AppColors.maroon,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Bottom Action Section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        _handleReturnVehicle(rentalId, vName),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.maroon,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'AJUKAN PENGEMBALIAN',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
