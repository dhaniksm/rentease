import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    fetchHistoryData();
  }

  Future<void> fetchHistoryData() async {
    final url = Uri.parse('${baseUrl}api/history'); 
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          historyData = data is List ? data : (data['data'] ?? []);
          if (historyData.isEmpty) {
            _loadMockData();
          }
          isLoading = false;
        });
      } else {
        setState(() {
          _loadMockData();
          isLoading = false;
        });
        debugPrint('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loadMockData();
        isLoading = false;
      });
      debugPrint('Error: $e');
    }
  }

  void _loadMockData() {
    historyData = [
      {
        "vehicle_name": "AVANZA 2017 - W 7777 P",
        "renter_name": "Lovya Cantik",
        "waktu_sewa": "7 hari",
        "pickup": "21-05-2026",
        "pengembalian": "27-05-2026",
        "total_pembayaran": "Rp. 5.000.000",
        "denda": ""
      },
      {
        "vehicle_name": "AVANZA 2017 - W 7777 P",
        "renter_name": "Lovya Cantik",
        "waktu_sewa": "7 hari",
        "pickup": "21-05-2026",
        "pengembalian": "27-05-2026",
        "total_pembayaran": "Rp. 5.000.000",
        "denda": ""
      },
      {
        "vehicle_name": "SCOOPY 2018 - P 8888 W",
        "renter_name": "Adel Bondowoso",
        "waktu_sewa": "3 hari",
        "pickup": "21-05-2026",
        "pengembalian": "23-05-2026",
        "total_pembayaran": "Rp. 225.00.000",
        "denda": ""
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF6B0B1E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=5',
            ),
          ),
        ),
        title: const Text(
          'RIWAYAT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 32),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['vehicle_name'] ?? 'AVANZA 2017 - W 7777 P',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['renter_name'] ?? 'Lovya Cantik',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow('Waktu Sewa', item['waktu_sewa'] ?? '-'),
                            const SizedBox(height: 4),
                            _buildDetailRow('Pickup', item['pickup'] ?? '-'),
                            const SizedBox(height: 4),
                            _buildDetailRow('Pengembalian', item['pengembalian'] ?? '-'),
                            const SizedBox(height: 4),
                            _buildDetailRow('Total Pembayaran', item['total_pembayaran'] ?? '-'),
                            const SizedBox(height: 4),
                            _buildDetailRow('Denda', item['denda'] ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        currentIndex: 4, 
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home, size: 28),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 28),
            label: 'SCAN QR',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined, size: 28),
            activeIcon: Icon(Icons.location_on, size: 28),
            label: 'MAP',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined, size: 28), 
            label: 'PEMBAYARAN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 28),
            label: 'RIWAYAT',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
