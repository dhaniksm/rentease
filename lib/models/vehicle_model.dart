class VehicleModel {
  final String id;
  final String vehicleName;
  final String brand;
  final String vehicleType;
  final String plateNumber;
  final String chassisNumber;
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
    this.chassisNumber = '',
    required this.pricePerDay,
    required this.status,
    this.imageUrl,
    this.description,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id']?.toString() ?? '',
      vehicleName: json['vehicle_name'] ?? json['name'] ?? json['nama'] ?? '',
      brand: json['brand'] ?? json['merk'] ?? '',
      vehicleType:
          json['vehicle_type'] ?? json['type'] ?? json['jenis'] ?? 'motor',
      plateNumber:
          json['plate_number'] ?? json['plate'] ?? json['plat_nomor'] ?? '',
      chassisNumber: json['chassis_number'] ?? json['nomor_rangka'] ?? '',
      pricePerDay: _toInt(
        json['price_per_day'] ?? json['price'] ?? json['harga'],
      ),
      status: json['status'] ?? 'available',
      imageUrl: json['image_url'] ?? json['photo_url'] ?? json['foto'],
      description: json['description'] ?? json['deskripsi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicle_name': vehicleName,
      'brand': brand,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'chassis_number': chassisNumber,
      'price_per_day': pricePerDay,
      'status': status,
      'image_url': imageUrl,
      'description': description,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? vehicleName,
    String? brand,
    String? vehicleType,
    String? plateNumber,
    String? chassisNumber,
    int? pricePerDay,
    String? status,
    String? imageUrl,
    String? description,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleName: vehicleName ?? this.vehicleName,
      brand: brand ?? this.brand,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.replaceAll('.', '')) ?? 0;
    return 0;
  }
}
