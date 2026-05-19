import 'package:rentease/core/supabase_config.dart';
import 'package:rentease/models/vehicle_model.dart';

class VehicleService {

  Future<void> addVehicle(VehicleModel vehicle) async {
    await supabase
        .from('vehicles')
        .insert(vehicle.toJson());
  }

  Future<List<VehicleModel>> getVehicles() async {

    final response = await supabase
        .from('vehicles')
        .select();

    return response
        .map<VehicleModel>(
          (json) => VehicleModel.fromJson(json),
        )
        .toList();
  }

  Future<void> deleteVehicle(String id) async {
    await supabase
        .from('vehicles')
        .delete()
        .eq('id', id);
  }
}