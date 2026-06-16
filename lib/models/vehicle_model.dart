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
  final double rating;
  final String transmission;
  final int capacity;

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
    this.rating = 0.0,
    this.transmission = 'Manual',
    this.capacity = 4,
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
      pricePerDay: _toInt(
        json['price_per_day'] ?? json['price'] ?? json['harga'],
      ),
      status: json['status'] ?? 'available',
      imageUrl: json['image_url'] ?? json['photo_url'] ?? json['foto'],
      description: json['description'] ?? json['deskripsi'],
      rating: _toDouble(json['rating']),
      transmission: json['transmission'] ?? json['transmisi'] ?? 'Otomatis',
      capacity: _toInt(json['capacity'] ?? json['kapasitas'] ?? 4),
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
      'rating': rating,
      'transmission': transmission,
      'capacity': capacity,
    };
  }

  VehicleModel copyWith({
    String? id,
    String? vehicleName,
    String? brand,
    String? vehicleType,
    String? plateNumber,
    int? pricePerDay,
    String? status,
    String? imageUrl,
    String? description,
    double? rating,
    String? transmission,
    int? capacity,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      vehicleName: vehicleName ?? this.vehicleName,
      brand: brand ?? this.brand,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      transmission: transmission ?? this.transmission,
      capacity: capacity ?? this.capacity,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value.replaceAll('.', '')) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
