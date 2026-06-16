import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchHistoryData();
    });
  }

  Future<void> fetchHistoryData() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final rentalProvider = context.read<RentalProvider>();
      await rentalProvider.loadRentals(); // load all rentals for admin

      if (!mounted) return;
      setState(() {
        historyData = rentalProvider.rawRentals;
        if (historyData.isEmpty) {
          _loadMockData();
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadMockData();
      });
      debugPrint('Error: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMockData() {
    historyData = [];
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

  String _getStatusText(String? status) {
    if (status == 'returned') return 'SELESAI';
    if (status == 'active') return 'SEDANG DISEWA';
    if (status == 'canceled' || status == 'cancelled') return 'DIBATALKAN';
    return status?.toUpperCase() ?? 'MENUNGGU';
  }

  Color _getStatusColor(String? status) {
    if (status == 'returned') return Colors.green.shade600;
    if (status == 'active') return Colors.blue.shade600;
    if (status == 'canceled' || status == 'cancelled')
      return Colors.red.shade600;
    return Colors.orange.shade600;
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
          'RIWAYAT SEWA',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.maroon, size: 28),
            onPressed: fetchHistoryData,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchHistoryData,
              color: AppColors.maroon,
              child: isLoading && historyData.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : historyData.isEmpty
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
                                Icons.history_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat penyewaan.',
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final item = historyData[index];
                        final imageUrl = item['vehicle_image_url'] ?? item['image_url'];
                        final String startDate =
                            item['start_date'] ?? item['waktu_sewa'] ?? '';
                        final int totalDays =
                            item['total_days'] ?? item['durasi_sewa'] ?? 0;

                        final dynamic rawPrice =
                            item['total_price'] ??
                            item['total_pembayaran'] ??
                            0;
                        final totalPrice = rawPrice is double
                            ? rawPrice.toInt()
                            : (rawPrice is int ? rawPrice : 0);
                        final String status = item['status'] ?? item['rental_status'] ?? '-';

                        final statusColor = _getStatusColor(status);

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
                                              color: statusColor.withValues(
                                                alpha: 0.1,
                                              ),
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
                                                    color: statusColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  _getStatusText(status),
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            '${(item['vehicle_name'] ?? item['nama_kendaraan'] ?? 'KENDARAAN').toString().toUpperCase()} - ${item['plate_number'] ?? item['plat_nomor'] ?? '-'}',
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
                                              Icon(
                                                Icons.person,
                                                size: 14,
                                                color: AppColors.maroon
                                                    .withValues(alpha: 0.5),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  item['full_name'] ?? item['nama_penyewa'] ?? 'Unknown User',
                                                  style: TextStyle(
                                                    color: AppColors.maroon
                                                        .withValues(alpha: 0.7),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                              // Bottom Section (Price & Duration)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.maroon.withValues(
                                    alpha: 0.04,
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(22),
                                    bottomRight: Radius.circular(22),
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
                                          'Total Pembayaran',
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
