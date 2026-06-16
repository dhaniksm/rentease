import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease/providers/dashboard_provider.dart';
import 'package:rentease/utils/app_colors.dart';
import 'package:rentease/screens/user/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToHistory;

  const DashboardScreen({super.key, this.onNavigateToHistory});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadDashboardSummary().then((_) {
        if (mounted) _animController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final summary = dashboardProvider.dashboardSummary;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'DASHBOARD',
          style: TextStyle(
            color: AppColors.maroon,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundColor: AppColors.maroon.withValues(alpha: 0.1),
              child: const Icon(Icons.person, color: AppColors.maroon),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.maroon),
            onPressed: () {
              _animController.reset();
              context.read<DashboardProvider>().loadDashboardSummary().then((
                _,
              ) {
                _animController.forward();
              });
            },
          ),
        ],
      ),
      body: dashboardProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.maroon),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                color: AppColors.maroon,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await context
                      .read<DashboardProvider>()
                      .loadDashboardSummary();
                  _animController.forward(from: 0);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Revenue Card
                      _buildRevenueCard(summary?.totalRevenue ?? 0),
                      const SizedBox(height: 24),

                      // Quick Stats Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildGlassCard(
                              title: 'TOTAL SEWA',
                              value:
                                  summary?.completedRentals.toString() ?? '0',
                              icon: Icons.assignment_turned_in,
                              color: AppColors.maroon,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildGlassCard(
                              title: 'UNIT AKTIF',
                              value: summary?.activeRentals.toString() ?? '0',
                              icon: Icons.car_rental,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Secondary Stats
                      _buildSecondaryStats(summary),
                      const SizedBox(height: 32),

                      // Recent Transactions Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Penyewaan Terkini',
                            style: TextStyle(
                              color: AppColors.maroon,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onNavigateToHistory,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.maroon.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  color: AppColors.maroon,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Recent Transactions List
                      if (dashboardProvider.recentTransactions.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'Belum ada transaksi.',
                              style: TextStyle(
                                color: AppColors.maroon.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        )
                      else
                        ...dashboardProvider.recentTransactions.take(4).map((
                          trx,
                        ) {
                          return _buildRecentItem(
                            title:
                                '${trx['brand'] ?? ''} ${trx['vehicle_name'] ?? trx['nama_kendaraan'] ?? 'KENDARAAN'}'.trim(),
                            plate: trx['plate_number'] ?? trx['plat_nomor'] ?? '',
                            name: trx['full_name'] ?? trx['nama_penyewa'] ?? 'Anonim',
                            status: trx['status'] ?? trx['rental_status'] ?? 'Unknown',
                            date: trx['start_date'] ?? '',
                          );
                        }),

                      const SizedBox(height: 80), // Padding for bottom nav
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.maroon, AppColors.maroon.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Chart Curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: CustomPaint(
                painter: _CurvedChartPainter(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TOTAL PENDAPATAN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rp ${revenue.toStringAsFixed(0).replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: AppColors.maroon,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '+12.5%',
                            style: TextStyle(
                              color: AppColors.maroon,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bulan ini',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10,
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

  Widget _buildGlassCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.maroon,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: AppColors.maroon.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats(dynamic summary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMiniStat(
            'User',
            summary?.totalUsers.toString() ?? '0',
            Icons.people,
          ),
          _buildDivider(),
          _buildMiniStat(
            'Armada',
            summary?.totalVehicles.toString() ?? '0',
            Icons.two_wheeler,
          ),
          _buildDivider(),
          _buildMiniStat(
            'Tersedia',
            summary?.availableVehicles.toString() ?? '0',
            Icons.check_circle_outline,
          ),
          _buildDivider(),
          _buildMiniStat(
            'Disewa',
            summary?.rentedVehicles.toString() ?? '0',
            Icons.key,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.maroon, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.maroon,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.maroon.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.maroon.withValues(alpha: 0.2),
    );
  }

  Widget _buildRecentItem({
    required String title,
    required String plate,
    required String name,
    required String status,
    required String date,
  }) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'AKTIF';
        break;
      case 'paid':
        statusColor = Colors.orange;
        statusText = 'LUNAS';
        break;
      case 'completed':
        statusColor = Colors.blue;
        statusText = 'SELESAI';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.maroon.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long, color: statusColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.maroon,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$name • $plate',
                  style: TextStyle(
                    color: AppColors.maroon.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                date.split('T').first,
                style: TextStyle(
                  color: AppColors.maroon.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Premium Curved Chart
class _CurvedChartPainter extends CustomPainter {
  final Color color;

  _CurvedChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.6,
      size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.8,
      size.height * 0.8,
      size.width * 1.0,
      size.height * 0.2,
      size.width,
      size.height * 0.2,
    );

    // Draw the gradient fill under the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
