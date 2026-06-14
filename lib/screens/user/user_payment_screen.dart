import 'package:rentease/providers/payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';
import 'package:rentease/widgets/primary_button.dart';

class UserRentalModel {
  final String id;
  final String? userId;
  final String? vehicleName;
  final String? plateNumber;
  final String? fullName;
  final String? startDate;
  final int totalDays;
  final int totalPrice;
  final String? rentalStatus;
  final String? paymentMethod;

  UserRentalModel({
    required this.id,
    this.userId,
    this.vehicleName,
    this.plateNumber,
    this.fullName,
    this.startDate,
    required this.totalDays,
    required this.totalPrice,
    this.rentalStatus,
    this.paymentMethod,
  });

  factory UserRentalModel.fromJson(Map<String, dynamic> json) {
    return UserRentalModel(
      id: json['id'] ?? '',
      userId: json['user_id']?.toString(),
      vehicleName:
          json['vehicle_name'] ?? json['nama_kendaraan'] ?? 'Unknown Vehicle',
      plateNumber: json['plate_number'] ?? json['plat_nomor'] ?? '-',
      fullName: json['full_name'] ?? json['nama_penyewa'] ?? 'Unknown Customer',
      startDate: json['start_date'] ?? json['waktu_sewa'],
      totalDays: json['total_days'] ?? json['durasi_sewa'] ?? 1,
      totalPrice:
          (json['total_price'] ?? json['total_pembayaran'] ?? 0) is double
          ? (json['total_price'] ?? json['total_pembayaran'] ?? 0).toInt()
          : (json['total_price'] ?? json['total_pembayaran'] ?? 0),
      rentalStatus: json['rental_status'] ?? json['status'] ?? 'unpaid',
      paymentMethod: json['payment_method'],
    );
  }
}

class UserPaymentScreen extends StatefulWidget {
  const UserPaymentScreen({super.key});

  @override
  State<UserPaymentScreen> createState() => _UserPaymentScreenState();
}

class _UserPaymentScreenState extends State<UserPaymentScreen> {
  List<UserRentalModel> _myRentals = [];
  bool _isLoading = false;
  int _selectedCardIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyRentals();
    });
  }

  Future<void> _fetchMyRentals() async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.profile == null) {
      await profileProvider.loadProfile();
    }

    final currentUserId = profileProvider.profile?.id;
    if (currentUserId == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.loadPayments();

      final allRentals = paymentProvider.rawPayments
          .map((json) => UserRentalModel.fromJson(json))
          .toList();

      if (!mounted) return;
      setState(() {
        _myRentals = allRentals
            .where((r) => r.userId == currentUserId)
            .toList();
        // Reset selection if out of bounds
        if (_selectedCardIndex >= _myRentals.length) {
          _selectedCardIndex = 0;
        }
      });
    } catch (e) {
      if (!mounted) return;
      _useMockFallback(currentUserId);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useMockFallback(String userId) {
    setState(() {
      _myRentals = [
        UserRentalModel(
          id: 'mock-1',
          userId: userId,
          vehicleName: 'MOBIL AVANZA',
          plateNumber: 'P 888 K',
          fullName: 'User RentEase',
          startDate: '2025-05-21',
          totalDays: 3,
          totalPrice: 750000,
          rentalStatus: 'unpaid',
        ),
      ];
    });
  }

  Future<void> _confirmPayment(String rentalId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.confirmPayment(rentalId);

      _showSnackBar(
        'Konfirmasi pembayaran terkirim! Menunggu verifikasi admin.',
        Colors.green.shade700,
      );
      _fetchMyRentals();
    } catch (e) {
      // Mock logic offline fallback
      if (rentalId.startsWith('mock-')) {
        setState(() {
          final idx = _myRentals.indexWhere((r) => r.id == rentalId);
          if (idx != -1) {
            final old = _myRentals[idx];
            _myRentals[idx] = UserRentalModel(
              id: old.id,
              userId: old.userId,
              vehicleName: old.vehicleName,
              plateNumber: old.plateNumber,
              fullName: old.fullName,
              startDate: old.startDate,
              totalDays: old.totalDays,
              totalPrice: old.totalPrice,
              rentalStatus: 'pending_verification',
            );
          }
        });
        _showSnackBar('Konfirmasi pembayaran (MOCK) terkirim!', Colors.green.shade700);
      } else {
        _showSnackBar('Koneksi internet bermasalah.', AppColors.maroon);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDateRange(String? startDateStr, int totalDays) {
    if (startDateStr == null) return '';
    try {
      final start = DateTime.parse(startDateStr);
      final end = start.add(Duration(days: totalDays - 1));

      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
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
    if (status == 'paid' || status == 'active' || status == 'returned') {
      return 'LUNAS';
    } else if (status == 'pending_verification') {
      return 'MENUNGGU VERIFIKASI';
    } else {
      return 'BELUM DIBAYAR';
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'paid' || status == 'active' || status == 'returned') {
      return Colors.green.shade600;
    } else if (status == 'pending_verification') {
      return Colors.orange.shade600;
    } else {
      return AppColors.maroon;
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
          'PEMBAYARAN',
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
              onRefresh: _fetchMyRentals,
              color: AppColors.maroon,
              child: _isLoading && _myRentals.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.maroon),
                    )
                  : _myRentals.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Belum ada transaksi pembayaran.',
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      itemCount: _myRentals.length,
                      itemBuilder: (context, index) {
                        final rental = _myRentals[index];
                        final isSelected = index == _selectedCardIndex;
                        final statusColor = _getStatusColor(rental.rentalStatus);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCardIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.maroon 
                                    : AppColors.maroon.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected 
                                      ? AppColors.maroon.withValues(alpha: 0.15)
                                      : AppColors.maroon.withValues(alpha: 0.05),
                                  blurRadius: isSelected ? 20 : 10,
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
                                      // Status Dot & Dates
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(12),
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
                                                    _getStatusText(rental.rentalStatus),
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
                                              '${rental.vehicleName?.toUpperCase()} - ${rental.plateNumber}',
                                              style: const TextStyle(
                                                color: AppColors.maroon,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.maroon.withValues(alpha: 0.5)),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDateRange(rental.startDate, rental.totalDays),
                                                  style: TextStyle(
                                                    color: AppColors.maroon.withValues(alpha: 0.7),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.maroon.withValues(alpha: 0.04),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      bottomRight: Radius.circular(22),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Durasi Sewa',
                                            style: TextStyle(
                                              color: AppColors.maroon.withValues(alpha: 0.5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${rental.totalDays} Hari',
                                            style: const TextStyle(
                                              color: AppColors.maroon,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Total Tagihan',
                                            style: TextStyle(
                                              color: AppColors.maroon.withValues(alpha: 0.5),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            Formatters.rupiah(rental.totalPrice),
                                            style: const TextStyle(
                                              color: AppColors.maroon,
                                              fontSize: 18,
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
                          ),
                        );
                      },
                    ),
            ),
          ),

          // BOTTOM ACTION BAR
          if (_myRentals.isNotEmpty)
            Container(
              padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
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
                text: 'KONFIRMASI PEMBAYARAN',
                isLoading: _isLoading,
                onPressed: _myRentals[_selectedCardIndex].rentalStatus != 'unpaid'
                    ? null
                    : () => _confirmPayment(_myRentals[_selectedCardIndex].id),
              ),
            ),
        ],
      ),
    );
  }
}
