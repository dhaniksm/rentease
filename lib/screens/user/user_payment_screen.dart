import 'package:rentease/providers/payment_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rentease/providers/profile_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';

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
    _fetchMyRentals();
  }

  Future<void> _fetchMyRentals() async {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.profile == null) {
      await profileProvider.loadProfile();
    }

    final currentUserId = profileProvider.profile?.id;
    if (currentUserId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.loadPayments();

      final allRentals = paymentProvider.rawPayments
          .map((json) => UserRentalModel.fromJson(json))
          .toList();

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
      _useMockFallback(currentUserId);
    } finally {
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
        Colors.green,
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
        _showSnackBar('Konfirmasi pembayaran (MOCK) terkirim!', Colors.green);
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
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: bg,
      ),
    );
  }

  String _formatDateRange(String? startDateStr, int totalDays) {
    if (startDateStr == null) return '';
    try {
      final start = DateTime.parse(startDateStr);
      final end = start.add(Duration(days: totalDays - 1));

      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
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
      return 'Sudah Dibayar';
    } else if (status == 'pending_verification') {
      return 'Menunggu Verifikasi';
    } else {
      return 'Menunggu';
    }
  }

  Color _getStatusColor(String? status) {
    if (status == 'paid' || status == 'active' || status == 'returned') {
      return const Color(0xFF2E7D32); // Green
    } else if (status == 'pending_verification') {
      return const Color(0xFFEF6C00); // Orange
    } else {
      return const Color(0xFFC62828); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar exactly matching Figma mockup style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button with circular/rounded container
                  GestureDetector(
                    onTap: () {
                      // Navigate back or switch tab to Home (index 0)
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.maroon.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.maroon,
                        size: 24,
                      ),
                    ),
                  ),
                  const Text(
                    'PEMBAYARAN',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.maroon,
                      letterSpacing: 1.2,
                    ),
                  ),
                  // Heart icon with circular/rounded container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.maroon.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: AppColors.maroon,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Main maroon card area
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMyRentals,
                color: AppColors.maroon,
                child: _isLoading && _myRentals.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.maroon,
                        ),
                      )
                    : _myRentals.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada transaksi pembayaran.',
                          style: TextStyle(
                            color: AppColors.maroon,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white, // Light theme background
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppColors.maroon.withOpacity(0.2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.maroon.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _myRentals.length,
                          itemBuilder: (context, index) {
                            final rental = _myRentals[index];
                            final isSelected = index == _selectedCardIndex;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCardIndex = index;
                                });
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Vehicle Header Text
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      bottom: 8,
                                    ),
                                    child: Text(
                                      '${rental.vehicleName?.toUpperCase()} - ${rental.plateNumber}',
                                      style: const TextStyle(
                                        color: AppColors.maroon,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  // Inner White Details Box matching mockup exactly
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: AppColors.maroon.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                              color: isSelected ? AppColors.maroon : AppColors.maroon.withOpacity(0.2),
                                              width: isSelected ? 3 : 1.5,
                                            ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Duration (e.g. "3 Hari")
                                            Text(
                                              '${rental.totalDays} Hari',
                                              style: const TextStyle(
                                                color: AppColors.maroon,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                            // Price
                                            Text(
                                              Formatters.rupiah(
                                                rental.totalPrice,
                                              ),
                                              style: const TextStyle(
                                                color: AppColors.maroon,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Date range (e.g. "21 - 23 Mei 2025")
                                            Text(
                                              _formatDateRange(
                                                rental.startDate,
                                                rental.totalDays,
                                              ),
                                              style: const TextStyle(
                                                color: AppColors.maroon,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            // Status
                                            Text(
                                              _getStatusText(
                                                rental.rentalStatus,
                                              ),
                                              style: TextStyle(
                                                color: _getStatusColor(
                                                  rental.rentalStatus,
                                                ),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),

            // Bottom bar with dynamic confirmation action button
            if (_myRentals.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                          _isLoading ||
                              _myRentals[_selectedCardIndex].rentalStatus !=
                                  'unpaid'
                          ? null
                          : () {
                              _confirmPayment(
                                _myRentals[_selectedCardIndex].id,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade600,
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Konfirmasi',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
