class DashboardModel {
  final int totalUsers;
  final int totalVehicles;
  final int availableVehicles;
  final int rentedVehicles;
  final int maintenanceVehicles;
  final int activeRentals;
  final int completedRentals;
  final double totalRevenue;
  final double monthlyRevenue;

  DashboardModel({
    required this.totalUsers,
    required this.totalVehicles,
    required this.availableVehicles,
    required this.rentedVehicles,
    required this.maintenanceVehicles,
    required this.activeRentals,
    required this.completedRentals,
    required this.totalRevenue,
    required this.monthlyRevenue,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalUsers: json['total_users'] ?? 0,
      totalVehicles: json['total_vehicles'] ?? 0,
      availableVehicles: json['available_vehicles'] ?? 0,
      rentedVehicles: json['rented_vehicles'] ?? 0,
      maintenanceVehicles: json['maintenance_vehicles'] ?? 0,
      activeRentals: json['active_rentals'] ?? 0,
      completedRentals: json['completed_rentals'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_vehicles': totalVehicles,
      'available_vehicles': availableVehicles,
      'rented_vehicles': rentedVehicles,
      'maintenance_vehicles': maintenanceVehicles,
      'active_rentals': activeRentals,
      'completed_rentals': completedRentals,
      'total_revenue': totalRevenue,
      'monthly_revenue': monthlyRevenue,
    };
  }
}
