import 'package:flutter/material.dart';
import 'package:rentease/models/vehicle_model.dart';
import 'package:rentease/services/vehicle_service.dart';
import 'package:rentease/services/auth_service.dart';

class VehicleScreen extends StatefulWidget {
  const VehicleScreen({super.key});

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen> {

  final VehicleService vehicleService = VehicleService();

  final AuthService authService = AuthService();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController brandController =
      TextEditingController();

  final TextEditingController plateController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  List<VehicleModel> vehicles = [];

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {

    final data = await vehicleService.getVehicles();

    setState(() {
      vehicles = data;
    });
  }

  Future<void> addVehicle() async {

    final vehicle = VehicleModel(
      id: '',
      vehicleName: nameController.text,
      brand: brandController.text,
      vehicleType: 'car',
      plateNumber: plateController.text,
      pricePerDay: int.parse(priceController.text),
      status: 'available',
    );

    await vehicleService.addVehicle(vehicle);

    nameController.clear();
    brandController.clear();
    plateController.clear();
    priceController.clear();

    loadVehicles();
  }

  Future<void> deleteVehicle(String id) async {

    await vehicleService.deleteVehicle(id);

    loadVehicles();
  }

    Future<void> logout() async {
    await authService.logout();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicles'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
              ),
            ),

            TextField(
              controller: brandController,
              decoration: const InputDecoration(
                labelText: 'Brand',
              ),
            ),

            TextField(
              controller: plateController,
              decoration: const InputDecoration(
                labelText: 'Plate Number',
              ),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Price Per Day',
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: addVehicle,
              child: const Text('Add Vehicle'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: logout,
              child: const Text('Logout')),

            Expanded(
              child: ListView.builder(
                itemCount: vehicles.length,

                itemBuilder: (context, index) {

                  final vehicle = vehicles[index];

                  return Card(
                    child: ListTile(
                      title: Text(vehicle.vehicleName),

                      subtitle: Text(
                        '${vehicle.brand} | ${vehicle.plateNumber}',
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete),

                        onPressed: () {
                          deleteVehicle(vehicle.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}