import 'package:flutter/material.dart';
import 'package:rentease/utils/app_colors.dart';

class RentalCheckoutScreen extends StatelessWidget {
  const RentalCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.maroon, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.maroon,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Calendar Illustration Card
                    Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Calendar outline simulation
                          Positioned(
                            top: 40,
                            child: Container(
                              width: 250,
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.maroon.withOpacity(0.5),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 100,
                            child: Container(
                              width: 2,
                              height: 30,
                              color: AppColors.maroon.withOpacity(0.5),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            right: 100,
                            child: Container(
                              width: 2,
                              height: 30,
                              color: AppColors.maroon.withOpacity(0.5),
                            ),
                          ),
                          Positioned(
                            top: 110,
                            child: Container(
                              width: 240,
                              height: 1.5,
                              color: AppColors.maroon.withOpacity(0.5),
                            ),
                          ),
                          // The 6 dots
                          Positioned(top: 160, left: 105, child: _buildDot()),
                          Positioned(top: 160, left: 165, child: _buildDot()),
                          Positioned(top: 160, left: 225, child: _buildDot()),
                          Positioned(top: 220, left: 105, child: _buildDot()),
                          Positioned(top: 220, left: 165, child: _buildDot()),
                          Positioned(top: 220, left: 225, child: _buildDot()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Info Row 1 (Duration & Price)
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoPill(
                            '3 hari\n21 - 23 Mei 2025',
                            height: 75,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoPill(
                            'Rp750.000',
                            height: 75,
                            centerText: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Vehicle Name Row
                    _buildInfoPill(
                      'Mobil imup b;la\nsnbdcdchd',
                      height: 85,
                      centerText: true,
                      fullWidth: true,
                    ),
                    const SizedBox(height: 20),
                    // Three Blank Squares Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBlankSquare(),
                        _buildBlankSquare(),
                        _buildBlankSquare(),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bottom Bar / Checkout Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.maroon.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pemesanan Berhasil Dikonfirmasi!'),
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'SEWA SEKARANG',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.maroon.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInfoPill(
    String text, {
    required double height,
    bool centerText = false,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      alignment: centerText ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: centerText ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          color: AppColors.maroon,
          fontWeight: FontWeight.bold,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBlankSquare() {
    return Container(
      width: 100,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.maroon.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
