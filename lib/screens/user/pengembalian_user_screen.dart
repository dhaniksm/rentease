import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';
import 'package:rentease/screens/user/profile_screen.dart';

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
    fetchActiveRentals();
  }

  Future<void> fetchActiveRentals() async {
    setState(() {
      isLoading = true;
    });

    try {
      final profileProvider = context.read<ProfileProvider>();
      if (profileProvider.profile == null) {
        await profileProvider.loadProfile();
      }
      final userId = profileProvider.profile?.id;

      if (userId != null) {
        final rentalProvider = context.read<RentalProvider>();
        await rentalProvider.loadUserRentals(userId);

        setState(() {
          // Filter only active rentals
          activeRentals = rentalProvider.rawRentals.where((rental) {
            final status = rental['status'] ?? rental['rental_status'] ?? '';
            return status == 'active';
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _handleReturnVehicle(String rentalId, String vehicleName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Konfirmasi Pengembalian',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin mengajukan pengembalian untuk $vehicleName?',
          style: const TextStyle(color: Colors.black87),
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

    try {
      await context.read<RentalProvider>().returnRental(rentalId);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil mengajukan pengembalian kendaraan!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload active rentals
      fetchActiveRentals();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan pengembalian: $e'),
          backgroundColor: AppColors.maroon,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = AppColors.maroon;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PENGEMBALIAN',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.maroon),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              color: primaryColor,
              onRefresh: fetchActiveRentals,
              child: activeRentals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.car_rental,
                            size: 80,
                            color: primaryColor.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada kendaraan yang sedang disewa.',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: activeRentals.length,
                      itemBuilder: (context, index) {
                        final rental = activeRentals[index];
                        final rentalId = rental['id'] ?? '';
                        final vehicle = rental['vehicle'] ?? {};
                        final vName = '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''}';
                        final plate = vehicle['plate_number'] ?? '-';
                        
                        // Parse numbers safely
                        final totalDays = rental['total_days'] ?? rental['durasi_sewa'] ?? 0;
                        final dynamic rawPrice = rental['total_price'] ?? rental['total_pembayaran'] ?? 0;
                        final totalPrice = rawPrice is double ? rawPrice.toInt() : (rawPrice is int ? rawPrice : 0);
                        
                        final startDate = rental['start_date'] ?? rental['waktu_sewa'] ?? '-';
                        final imageUrl = vehicle['image_url'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: primaryColor.withOpacity(0.3), width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Top info section
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.05),
                                        border: Border.all(color: primaryColor.withOpacity(0.2), width: 1.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: imageUrl != null && imageUrl.toString().isNotEmpty
                                            ? Image.network(imageUrl, fit: BoxFit.cover)
                                            : const Icon(Icons.directions_car, color: primaryColor, size: 40),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vName.toUpperCase(),
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 16,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              plate,
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          _buildDetailRow(Icons.calendar_today, 'Mulai: ${startDate.toString().split('T').first}'),
                                          const SizedBox(height: 4),
                                          _buildDetailRow(Icons.timer, 'Durasi: $totalDays Hari'),
                                          const SizedBox(height: 4),
                                          _buildDetailRow(Icons.payments, 'Total: ${Formatters.rupiah(totalPrice)}'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Bottom Action Section
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.05),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _handleReturnVehicle(rentalId, vName),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: const Text(
                                    'KEMBALIKAN KENDARAAN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
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
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.maroon.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: AppColors.maroon.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
