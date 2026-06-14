import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/providers/profile_provider.dart';

class RiwayatUserScreen extends StatefulWidget {
  const RiwayatUserScreen({super.key});

  @override
  State<RiwayatUserScreen> createState() => _RiwayatUserScreenState();
}

class _RiwayatUserScreenState extends State<RiwayatUserScreen> {
  final String baseUrl = 'https://rentase-api.vercel.app/';

  List<dynamic> historyData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
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
          historyData = rentalProvider.rawRentals;
          if (historyData.isEmpty) {
            _loadMockData();
          }
        });
      } else {
        _loadMockData();
      }
    } catch (e) {
      setState(() {
        _loadMockData();
      });
      debugPrint('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    historyData = [
      {
        "vehicle_name": "Adel Imup",
        "waktu_sewa": "7 hari",
        "pickup": "21-05-2026",
        "pengembalian": "27-05-2026",
        "total_pembayaran": "Rp. 5.000.000",
        "denda": "0",
      },
    ];
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
          'RIWAYAT',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: primaryColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['vehicle_name'] ?? 'Adel Imup',
                              style: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Waktu Sewa',
                              item['waktu_sewa'] ?? '-',
                            ),
                            const SizedBox(height: 4),
                            _buildDetailRow('Pickup', item['pickup'] ?? '-'),
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              'Pengembalian',
                              item['pengembalian'] ?? '-',
                            ),
                            const SizedBox(height: 4),
                            _buildDetailRow(
                              'Total Pembayaran',
                              item['total_pembayaran'] ?? '-',
                            ),
                            const SizedBox(height: 4),
                            _buildDetailRow('Denda', item['denda'] ?? '-'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    const Color primaryColor = AppColors.maroon;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

