class RentalModel {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;
  final DateTime? createdAt;

  RentalModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });

  factory RentalModel.fromJson(Map<String, dynamic> json) {
    return RentalModel(
      id: json['id'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      userId: json['user_id'] ?? '',
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      status: json['status'] ?? json['rental_status'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'status': status,
    };
  }
}
