import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/rental_provider.dart';
import 'package:rentease/utils/app_colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Pre-load rentals when scanner opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().loadRentals();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? qrData = barcodes.first.rawValue;
    if (qrData == null || qrData.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    _scannerController.stop();

    await _processQrData(qrData);

    // After processing (whether success or fail/canceled), we might want to resume
    // but usually we stay on the result or go back to scanning
    setState(() {
      _isProcessing = false;
    });
    _scannerController.start();
  }

  Future<void> _processQrData(String qrData) async {
    final provider = context.read<RentalProvider>();
    final rawRentals = provider.rawRentals;

    // Find active/paid rental matching the qrData
    // We check if qrData matches vehicle_id OR plate_number
    Map<String, dynamic>? matchedRental;

    for (var rental in rawRentals) {
      final status = rental['status'] ?? rental['rental_status'] ?? '';
      if (status != 'paid' && status != 'active') continue;

      final vId = rental['vehicle_id']?.toString() ?? '';
      final vehicle = rental['vehicle'] ?? {};
      final plate = vehicle['plate_number']?.toString() ?? '';

      if (qrData == vId || qrData == plate) {
        matchedRental = rental;
        break;
      }
    }

    if (matchedRental == null) {
      await _showErrorDialog('Tidak ditemukan penyewaan aktif atau lunas untuk kode QR ini.\n\nData QR: $qrData');
      return;
    }

    final status = matchedRental['status'] ?? matchedRental['rental_status'];
    final rentalId = matchedRental['id'] ?? '';
    final vehicle = matchedRental['vehicle'] ?? {};
    final vName = '${vehicle['brand'] ?? ''} ${vehicle['vehicle_name'] ?? ''} - ${vehicle['plate_number'] ?? ''}';

    if (status == 'paid') {
      final confirm = await _showConfirmDialog(
        'Konfirmasi Pengambilan (Pickup)',
        'Tandai $vName sebagai telah diambil oleh penyewa?\nStatus akan berubah menjadi Active.',
      );
      if (confirm == true) {
        await _executeAction(provider.verifyVehicle(rentalId), 'Pickup berhasil dikonfirmasi!');
      }
    } else if (status == 'active') {
      final confirm = await _showConfirmDialog(
        'Konfirmasi Pengembalian (Return)',
        'Tandai $vName sebagai telah dikembalikan?\nStatus akan berubah menjadi Completed.',
      );
      if (confirm == true) {
        await _executeAction(provider.returnRental(rentalId), 'Pengembalian berhasil dikonfirmasi!');
      }
    }
  }

  Future<void> _executeAction(Future<void> action, String successMessage) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.maroon)),
    );

    try {
      await action;
      if (mounted) Navigator.pop(context); // close loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // close loading
      await _showErrorDialog('Gagal memproses permintaan:\n$e');
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.maroon),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Konfirmasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Pemindaian Gagal', style: TextStyle(color: AppColors.maroon, fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: AppColors.maroon)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'SCAN QR',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Arahkan kamera ke QR Code yang tertempel di Kendaraan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                ),
                // Overlay viewfinder box
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _scannerController.toggleTorch();
              },
              icon: const Icon(Icons.flash_on, color: Colors.white),
              label: const Text('Senter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maroon,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
