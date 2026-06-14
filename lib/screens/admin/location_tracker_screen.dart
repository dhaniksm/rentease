import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/providers/rental_provider.dart';

class LocationTrackerScreen extends StatefulWidget {
  const LocationTrackerScreen({super.key});

  @override
  State<LocationTrackerScreen> createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  int _selectedIndex = 0; // selected marker index
  List<dynamic> _activeRentals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveRentals();
  }

  Future<void> _fetchActiveRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rentalProvider = context.read<RentalProvider>();
      await rentalProvider.loadRentals(); // load all rentals for admin

      setState(() {
        _activeRentals = rentalProvider.rawRentals.where((rental) {
          return rental['status'] == 'active' || rental['status'] == 'paid';
        }).toList();
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Predefined offsets for the fake map
  final List<Offset> _markerOffsets = const [
    Offset(60, 80),
    Offset(150, 200),
    Offset(250, 120),
    Offset(100, 280),
    Offset(200, 350),
    Offset(40, 180),
    Offset(280, 50),
  ];

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
          'MAP',
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
            onPressed: _fetchActiveRentals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.maroon))
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.maroon.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maroon.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: AppColors.maroon),
                        hintText: 'Cari Kendaraan',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Map Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage('assets/images/dark_map.png'),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: AppColors.maroon.withOpacity(0.5), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: _buildMapMarkers(),
                      ),
                    ),
                  ),
                ),

                // Detail Card
                if (_activeRentals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildSelectedDetailCard(),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Tidak ada kendaraan aktif.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
    );
  }

  List<Widget> _buildMapMarkers() {
    List<Widget> markers = [];
    for (int i = 0; i < _activeRentals.length; i++) {
      if (i >= _markerOffsets.length) break; // Limit to predefined offsets

      final isSelected = _selectedIndex == i;
      final offset = _markerOffsets[i];
      
      final vehicle = _activeRentals[i]['vehicle'] ?? {};
      final type = (vehicle['type'] ?? '').toString().toLowerCase();
      final icon = type.contains('motor') ? Icons.motorcycle : Icons.directions_car;
      final color = type.contains('motor') ? Colors.blue : Colors.green;

      markers.add(
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = i;
              });
            },
            child: _buildMarker(color, icon, isGlowing: isSelected),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildSelectedDetailCard() {
    if (_selectedIndex >= _activeRentals.length) return const SizedBox();
    
    final item = _activeRentals[_selectedIndex];
    final vehicle = item['vehicle'] ?? {};
    final profile = item['profiles'] ?? {};
    
    final String vName = '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''}'.trim();
    final String plate = vehicle['plate_number'] ?? '-';
    final String pName = profile['full_name'] ?? 'Unknown User';
    
    final String pickup = (item['start_date'] ?? '').split('T').first;
    final String pengembalian = (item['expected_return_date'] ?? '').split('T').first;
    final String totalDays = '${item['total_days'] ?? 1} hari';

    return Row(
      children: [
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.darkMaroon, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$vName - $plate'.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              Text(
                'Terhubung GPS Tracker via Vercel',
                style: TextStyle(
                  color: AppColors.maroon.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pName,
                style: const TextStyle(
                  color: AppColors.maroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              _buildDetailRow('Waktu Sewa', totalDays),
              _buildDetailRow('Pickup', pickup),
              _buildDetailRow('Pengembalian', pengembalian),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMarker(Color color, IconData icon, {bool isGlowing = false}) {
    return Container(
      decoration: isGlowing
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.6),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: color,
            size: 24,
            shadows: [if (isGlowing) Shadow(color: color, blurRadius: 10)],
          ),
        ],
      ),
    );
  }
}
