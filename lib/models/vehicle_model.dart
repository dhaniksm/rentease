class VehicleModel {
  final String id;
  final String vehicleName;
  final String brand;
  final String vehicleType;
  final String plateNumber;
  final int pricePerDay;
  final String status;
  final String? imageUrl;
  final String? description;

  VehicleModel({
    required this.id,
    required this.vehicleName,
    required this.brand,
    required this.vehicleType,
    required this.plateNumber,
    required this.pricePerDay,
    required this.status,
    this.imageUrl,
    this.description,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      vehicleName: json['vehicle_name'],
      brand: json['brand'],
      vehicleType: json['vehicle_type'],
      plateNumber: json['plate_number'],
      pricePerDay: json['price_per_day'],
      status: json['status'],
      imageUrl: json['image_url'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_name': vehicleName,
      'brand': brand,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'price_per_day': pricePerDay,
      'status': status,
      'image_url': imageUrl,
      'description': description,
    };
  }
}