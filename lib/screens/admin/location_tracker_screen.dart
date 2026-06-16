import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentease/services/location_api_service.dart';

class LocationTrackerScreen extends StatefulWidget {
  const LocationTrackerScreen({super.key});

  @override
  State<LocationTrackerScreen> createState() => _LocationTrackerScreenState();
}

class _LocationTrackerScreenState extends State<LocationTrackerScreen> {
  int _selectedIndex = 0; // selected marker index
  List<dynamic> _activeRentals = [];
  bool _isLoading = true;

  final MapController _mapController = MapController();

  // Center of Jakarta as default
  final LatLng _defaultCenter = const LatLng(-6.2088, 106.8456);

  // We'll store pseudo-random coordinates for each active rental
  final Map<String, LatLng> _rentalCoordinates = {};

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

      final rentals = rentalProvider.rawRentals.where((rental) {
        final status = rental['status'] ?? rental['rental_status'];
        return status == 'active' || status == 'paid';
      }).toList();

      // Fetch real coordinates from backend
      for (var rental in rentals) {
        final id = rental['id'].toString();
        try {
          final location = await LocationApiService().getLatestLocation(id);
          if (location != null) {
            _rentalCoordinates[id] = location;
          }
        } catch (e) {
          debugPrint('Error fetching location for $id: $e');
        }
      }

      setState(() {
        _activeRentals = rentals;
      });

      // If there are rentals, move map to the first one after a short delay
      if (_activeRentals.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _moveToSelectedMarker();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _moveToSelectedMarker() {
    if (_activeRentals.isEmpty || _selectedIndex >= _activeRentals.length)
      return;

    final id = _activeRentals[_selectedIndex]['id'].toString();
    final location = _rentalCoordinates[id];

    if (location != null) {
      _mapController.move(location, 14.0); // Zoom level 14
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'PELACAK LOKASI',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
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
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.maroon),
            )
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
                      border: Border.all(
                        color: AppColors.maroon.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.maroon.withValues(alpha: 0.05),
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
                        border: Border.all(
                          color: AppColors.maroon.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _defaultCenter,
                            initialZoom: 12.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.rentease',
                            ),
                            MarkerLayer(markers: _buildMapMarkers()),
                          ],
                        ),
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
                        border: Border.all(
                          color: AppColors.maroon.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.maroon.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
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

  List<Marker> _buildMapMarkers() {
    List<Marker> markers = [];
    for (int i = 0; i < _activeRentals.length; i++) {
      final isSelected = _selectedIndex == i;
      final item = _activeRentals[i];
      final id = item['id'].toString();

      final location = _rentalCoordinates[id] ?? _defaultCenter;

      final vehicle = item['vehicle'] ?? {};
      final type = (vehicle['type'] ?? '').toString().toLowerCase();
      final icon = type.contains('motor')
          ? Icons.motorcycle
          : Icons.directions_car;
      final color = type.contains('motor') ? Colors.blue : Colors.green;

      markers.add(
        Marker(
          point: location,
          width: 50,
          height: 50,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = i;
              });
              _moveToSelectedMarker();
            },
            child: _buildMarkerWidget(color, icon, isGlowing: isSelected),
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

    final String vName =
        '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''}'.trim();
    final String plate = vehicle['plate_number'] ?? '-';
    final String pName = profile['full_name'] ?? 'Unknown User';

    final String pickup = (item['start_date'] ?? '').split('T').first;
    final String pengembalian = (item['expected_return_date'] ?? '')
        .split('T')
        .first;
    final String totalDays = '${item['total_days'] ?? 1} hari';

    return Row(
      children: [
        Container(
          width: 80,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.maroon, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.car_rental, color: AppColors.maroon, size: 40),
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
                'Terhubung GPS Tracker',
                style: TextStyle(
                  color: AppColors.maroon.withValues(alpha: 0.7),
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

  Widget _buildMarkerWidget(
    Color color,
    IconData icon, {
    bool isGlowing = false,
  }) {
    return Container(
      decoration: isGlowing
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
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
              color: isGlowing ? AppColors.maroon : color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Icon(
            Icons.arrow_drop_down,
            color: isGlowing ? AppColors.maroon : color,
            size: 24,
            shadows: [
              if (isGlowing) Shadow(color: AppColors.maroon, blurRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}
