class LocationModel {
  final String id;
  final String rentalId;
  final double latitude;
  final double longitude;
  final DateTime? timestamp;

  LocationModel({
    required this.id,
    required this.rentalId,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] ?? '',
      rentalId: json['rental_id'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rental_id': rentalId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
