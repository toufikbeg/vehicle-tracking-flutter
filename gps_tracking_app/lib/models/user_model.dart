class UserModel {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final bool isActive;
  final int? assignedRouteId;
  final int? assignedVehicleId;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.isActive,
    this.assignedRouteId,
    this.assignedVehicleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      isActive: json['is_active'] ?? true,
      assignedRouteId: json['assigned_route_id'],
      assignedVehicleId: json['assigned_vehicle_id'],
    );
  }
}