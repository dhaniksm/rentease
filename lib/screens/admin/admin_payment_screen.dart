import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/payment_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/utils/formatters.dart';

// Model for Rental data to ensure Clean Code and type safety
class RentalModel {
  final String id;
  final String? vehicleName;
  final String? plateNumber;
  final String? fullName;
  final String? startDate;
  final int totalDays;
  final int totalPrice;
  final String? rentalStatus;
  final String? paymentMethod;
  final String? imageUrl;

  RentalModel({
    required this.id,
    this.vehicleName,
    this.plateNumber,
    this.fullName,
    this.startDate,
    required this.totalDays,
    required this.totalPrice,
    this.rentalStatus,
    this.paymentMethod,
    this.imageUrl,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] ?? '',
      vehicleName: json['vehicle_name'] ?? json['nama_kendaraan'] ?? 'Unknown Vehicle',
      plateNumber: json['plate_number'] ?? json['plat_nomor'] ?? '-',
      fullName: json['full_name'] ?? json['nama_penyewa'] ?? 'Unknown Customer',
      startDate: json['start_date'] ?? json['waktu_sewa'],
      totalDays: json['total_days'] ?? json['durasi_sewa'] ?? 1,
      totalPrice: (json['total_price'] ?? json['total_pembayaran'] ?? 0) is double
          ? (json['total_price'] ?? json['total_pembayaran'] ?? 0).toInt()
          : (json['total_price'] ?? json['total_pembayaran'] ?? 0),
      rentalStatus: json['rental_status'] ?? json['status'] ?? 'pending_verification',
      paymentMethod: json['payment_method'],
      imageUrl: json['vehicle'] != null ? json['vehicle']['image_url'] : null,
    );
  }
}

class AdminPaymentScreen extends StatefulWidget {
  const AdminPaymentScreen({super.key});

  @override
  State<AdminPaymentScreen> createState() => _AdminPaymentScreenState();
}

class _AdminPaymentScreenState extends State<AdminPaymentScreen> {
  List<RentalModel> _rentals = [];
  List<RentalModel> _filteredRentals = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedFilter = 'SEMUA'; // SEMUA, CASH, TRANSFER

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRentals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRentals() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.loadPayments();

      if (!mounted) return;
      setState(() {
        _rentals = paymentProvider.rawPayments
            .map((json) => RentalModel.fromJson(json))
            .toList();
        _applyFilterAndSearch();
      });
    } catch (e) {
      debugPrint('Error loading payments: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPayment(String id, String method) async {
    setState(() {
      _isLoading = true;
    });

    // Update locally immediately for Snappy UX
    final index = _rentals.indexWhere((r) => r.id == id);
    if (index != -1) {
      final oldRental = _rentals[index];
      setState(() {
        _rentals[index] = RentalModel(
          id: oldRental.id,
          vehicleName: oldRental.vehicleName,
          plateNumber: oldRental.plateNumber,
          fullName: oldRental.fullName,
          startDate: oldRental.startDate,
          totalDays: oldRental.totalDays,
          totalPrice: oldRental.totalPrice,
          rentalStatus: 'paid',
          paymentMethod: method,
          imageUrl: oldRental.imageUrl,
        );
        _applyFilterAndSearch();
      });
    }

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.verifyPayment(id);

      if (!mounted) return;
      _showSnackBar(
        'Pembayaran berhasil diverifikasi sebagai ${method.toUpperCase()}!',
        Colors.green.shade700,
      );
      _fetchRentals();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Gagal menghubungkan ke server untuk verifikasi.', AppColors.maroon);
      _fetchRentals();
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilterAndSearch() {
    List<RentalModel> temp = List.from(_rentals);

    if (_selectedFilter != 'SEMUA') {
      temp = temp.where((rental) {
        final method = rental.paymentMethod?.toLowerCase() ?? '';
        return method == _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      temp = temp.where((rental) {
        final vehicle = rental.vehicleName?.toLowerCase() ?? '';
        final renter = rental.fullName?.toLowerCase() ?? '';
        final plate = rental.plateNumber?.toLowerCase() ?? '';
        return vehicle.contains(query) || renter.contains(query) || plate.contains(query);
      }).toList();
    }

    setState(() {
      _filteredRentals = temp;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          'KELOLA PEMBAYARAN',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.maroon),
            onPressed: _fetchRentals,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _applyFilterAndSearch();
                    });
                  },
                  style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.maroon),
                    hintText: 'Cari penyewa atau kendaraan...',
                    hintStyle: TextStyle(color: AppColors.maroon.withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: AppColors.maroon.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('SEMUA'),
                      const SizedBox(width: 8),
                      _buildFilterChip('CASH'),
                      const SizedBox(width: 8),
                      _buildFilterChip('TRANSFER'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchRentals,
              color: AppColors.maroon,
              child: _isLoading && _filteredRentals.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
                  : _filteredRentals.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada data pembayaran.',
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _filteredRentals.length,
                      itemBuilder: (context, index) {
                        final rental = _filteredRentals[index];
                        final statusColor = _getStatusColor(rental.rentalStatus);
                        
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
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: AppColors.maroon.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: rental.imageUrl != null && rental.imageUrl!.isNotEmpty
                                            ? Image.network(rental.imageUrl!, fit: BoxFit.cover)
                                            : const Icon(Icons.directions_car, color: AppColors.maroon, size: 30),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
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
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 14, color: AppColors.maroon.withValues(alpha: 0.5)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  rental.fullName ?? 'Anonim',
                                                  style: TextStyle(
                                                    color: AppColors.maroon.withValues(alpha: 0.7),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                              // Bottom Section (Price & Verification)
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
                                          'Tagihan (${rental.totalDays} Hari)',
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Dropdown Verification
                                    Container(
                                      height: 36,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.maroon,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: (rental.paymentMethod == 'cash' || rental.paymentMethod == 'transfer')
                                              ? rental.paymentMethod
                                              : null,
                                          dropdownColor: AppColors.maroon,
                                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                                          hint: const Text(
                                            'VERIFIKASI',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'cash',
                                              child: Text('CASH', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                            DropdownMenuItem(
                                              value: 'transfer',
                                              child: Text('TRANSFER', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              _verifyPayment(rental.id, value);
                                            }
                                          },
                                        ),
                                      ),
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

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilterAndSearch();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.maroon : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.maroon : AppColors.maroon.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.maroon,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
