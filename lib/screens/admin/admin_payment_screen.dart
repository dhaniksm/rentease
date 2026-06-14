import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/payment_provider.dart';

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
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] ?? '',
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
      rentalStatus:
          json['rental_status'] ?? json['status'] ?? 'pending_verification',
      paymentMethod: json['payment_method'],
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

  // Colors matching Figma exactly
  final Color maroonDark = const Color(0xFF6B0014); // #6B0014
  final Color bgWhite = const Color(0xFFFFFFFF);
  final Color textBrownMuted = const Color(
    0xFF800000,
  ); // Maroon-brownish text for subtitle

  final TextEditingController _searchController = TextEditingController();

  // Mock data as fallback to ensure the UI matches the Figma screenshot instantly
  final List<RentalModel> _mockRentals = [];

  @override
  void initState() {
    super.initState();
    _fetchRentals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch rentals list from backend API (payments)
  Future<void> _fetchRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.loadPayments();

      setState(() {
        _rentals = paymentProvider.rawPayments
            .map((json) => RentalModel.fromJson(json))
            .toList();
        _applyFilterAndSearch();
      });
    } catch (e) {
      _useMockFallback();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useMockFallback() {
    setState(() {
      _rentals = List.from(_mockRentals);
      _applyFilterAndSearch();
    });
  }

  // Verify payment using Provider
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
        );
        _applyFilterAndSearch();
      });
    }

    try {
      final paymentProvider = context.read<PaymentProvider>();
      await paymentProvider.verifyPayment(id);

      _showSuccessSnackBar(
        'Pembayaran berhasil diverifikasi sebagai ${method.toUpperCase()}!',
      );
      _fetchRentals();
    } catch (e) {
      // If we are offline/using mocks, keep the simulated state
      if (id.startsWith('mock-')) {
        _showSuccessSnackBar(
          'Pembayaran (MOCK) berhasil diverifikasi sebagai ${method.toUpperCase()}!',
        );
      } else {
        _showErrorSnackBar('Gagal menghubungkan ke server untuk verifikasi.');
        _fetchRentals();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter and search logic
  void _applyFilterAndSearch() {
    List<RentalModel> temp = List.from(_rentals);

    // Apply Filter Tab
    if (_selectedFilter != 'SEMUA') {
      temp = temp.where((rental) {
        final method = rental.paymentMethod?.toLowerCase() ?? '';
        return method == _selectedFilter.toLowerCase();
      }).toList();
    }

    // Apply Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      temp = temp.where((rental) {
        final vehicle = rental.vehicleName?.toLowerCase() ?? '';
        final renter = rental.fullName?.toLowerCase() ?? '';
        final plate = rental.plateNumber?.toLowerCase() ?? '';
        return vehicle.contains(query) ||
            renter.contains(query) ||
            plate.contains(query);
      }).toList();
    }

    setState(() {
      _filteredRentals = temp;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: maroonDark),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[800]),
    );
  }

  // Helper to format currency exactly
  String _formatCurrency(int amount) {
    final valueString = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = valueString.length - 1; i >= 0; i--) {
      buffer.write(valueString[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp. ${buffer.toString().split('').reversed.join('')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 1. APP BAR
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: bgWhite),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundColor: maroonDark.withOpacity(0.1),
                      child: Icon(Icons.admin_panel_settings, color: maroonDark),
                    ),
                  ),
                  // App Bar Title
                  const Text(
                    'PEMBAYARAN',
                    style: TextStyle(
                      color: maroonDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  // Hamburger Menu Icon
                  IconButton(
                    icon: Icon(Icons.refresh, color: maroonDark, size: 28),
                    onPressed: _fetchRentals,
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchRentals,
                color: maroonDark,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // 3. SEARCH BAR
                      TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _applyFilterAndSearch();
                          });
                        },
                        style: TextStyle(
                          color: maroonDark,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.search,
                              color: maroonDark,
                              size: 28,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40,
                          ),
                          hintText: 'Cari',
                          hintStyle: TextStyle(
                            color: maroonDark.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: bgWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: maroonDark,
                              width: 1.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: maroonDark,
                              width: 2.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 4. FILTER TABS (Capsule shape)
                      Row(
                        children: [
                          _buildFilterButton('SEMUA'),
                          const SizedBox(width: 8),
                          _buildFilterButton('CASH'),
                          const SizedBox(width: 8),
                          _buildFilterButton('TRANSFER'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. LIST VIEW CARD ITEMS
                      _isLoading
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  color: maroonDark,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredRentals.length,
                              itemBuilder: (context, index) {
                                final rental = _filteredRentals[index];
                                return _buildRentalCard(rental);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter Button builder
  Widget _buildFilterButton(String label) {
    final bool isActive = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilterAndSearch();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? maroonDark : bgWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: maroonDark, width: 1.8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? bgWhite : maroonDark,
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // Rental Card builder
  Widget _buildRentalCard(RentalModel rental) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: maroonDark, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sisi Kiri: Blank vehicle image placeholder box
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: maroonDark, width: 1.5),
            ),
          ),
          const SizedBox(width: 14),

          // Sisi Kanan: Detail Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama & Plat Kendaraan
                Text(
                  '${rental.vehicleName?.toUpperCase()} - ${rental.plateNumber}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: maroonDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Nama Penyewa
                Text(
                  rental.fullName ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: textBrownMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),

                // Durasi Sewa
                Text(
                  '${rental.totalDays} hari',
                  style: TextStyle(
                    fontSize: 11,
                    color: textBrownMuted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),

                // Harga & Dropdown Verifikasi Pembayaran Admin
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrency(rental.totalPrice),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: maroonDark,
                      ),
                    ),

                    // Dropdown Button Form Field styled as a Maroon Capsule
                    SizedBox(
                      height: 28,
                      width: 125,
                      child: DropdownButtonFormField<String>(
                        value:
                            (rental.paymentMethod == 'cash' ||
                                rental.paymentMethod == 'transfer')
                            ? rental.paymentMethod
                            : null,
                        alignment: Alignment.centerRight,
                        dropdownColor: maroonDark,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                          filled: true,
                          fillColor: maroonDark,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                          size: 18,
                        ),
                        hint: const Text(
                          'PILIH',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'cash',
                            child: Text(
                              'CASH',
                              style: TextStyle(
                                color: (rental.paymentMethod == 'cash')
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'transfer',
                            child: Text(
                              'TRANSFER',
                              style: TextStyle(
                                color: (rental.paymentMethod == 'transfer')
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _verifyPayment(rental.id, value);
                          }
                        },
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
  }

}
