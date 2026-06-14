import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';

class RiwayatAdminScreen extends StatefulWidget {
  const RiwayatAdminScreen({super.key});

  @override
  State<RiwayatAdminScreen> createState() => _RiwayatAdminScreenState();
}

class _RiwayatAdminScreenState extends State<RiwayatAdminScreen> {
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
      final rentalProvider = context.read<RentalProvider>();
      await rentalProvider.loadRentals(); // load all rentals for admin

      setState(() {
        historyData = rentalProvider.rawRentals;
        if (historyData.isEmpty) {
          _loadMockData();
        }
      });
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
    historyData = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.maroon.withOpacity(0.1),
            child: const Icon(Icons.admin_panel_settings, color: AppColors.maroon),
          ),
        ),
        title: const Text(
          'RIWAYAT',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.maroon, size: 28),
            onPressed: fetchHistoryData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
          : historyData.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada riwayat penyewaan.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final item = historyData[index];
                    final vehicle = item['vehicle'] ?? {};
                    final profile = item['profiles'] ?? {};
                    
                    final String vName = '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''}'.trim();
                    final String pName = profile['full_name'] ?? 'Unknown User';
                    
                    final String pickup = (item['start_date'] ?? '').split('T').first;
                    final String pengembalian = (item['expected_return_date'] ?? '').split('T').first;
                    final String total = item['total_price']?.toString() ?? '0';
                    final String status = item['status'] ?? '-';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.maroon.withOpacity(0.2), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 110,
                            decoration: BoxDecoration(
                              color: AppColors.maroon.withOpacity(0.05),
                              border: Border.all(color: AppColors.maroon.withOpacity(0.2), width: 1.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vName.isNotEmpty ? vName : 'Kendaraan Tidak Diketahui',
                                  style: const TextStyle(
                                    color: AppColors.maroon,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pName,
                                  style: TextStyle(
                                    color: AppColors.maroon.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow('Status', status.toUpperCase()),
                                const SizedBox(height: 4),
                                _buildDetailRow('Pickup', pickup),
                                const SizedBox(height: 4),
                                _buildDetailRow('Pengembalian', pengembalian),
                                const SizedBox(height: 4),
                                _buildDetailRow('Total Harga', 'Rp $total'),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.maroon,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
