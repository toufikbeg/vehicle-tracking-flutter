class RouteInfo {
  final int id;
  final String routeName;
  final String routeCode;
  final String startLocation;
  final String endLocation;
  final List<Map<String, dynamic>>? waypoints;

  RouteInfo({
    required this.id,
    required this.routeName,
    required this.routeCode,
    required this.startLocation,
    required this.endLocation,
    this.waypoints,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      id: json['id'],
      routeName: json['route_name'],
      routeCode: json['route_code'],
      startLocation: json['start_location'],
      endLocation: json['end_location'],
      waypoints: json['waypoints'] != null
          ? List<Map<String, dynamic>>.from(json['waypoints'])
          : null,
    );
  }
}

class VehicleInfo {
  final int id;
  final String vehicleId;
  final String vehicleNumber;
  final String? model;
  final bool isActive;

  VehicleInfo({
    required this.id,
    required this.vehicleId,
    required this.vehicleNumber,
    this.model,
    required this.isActive,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      id: json['id'],
      vehicleId: json['vehicle_id'],
      vehicleNumber: json['vehicle_number'],
      model: json['model'],
      isActive: json['is_active'] ?? true,
    );
  }
}

class LocationInfo {
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null ? (json['heading'] as num).toDouble() : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class DashboardModel {
  final Map<String, dynamic> user;
  final RouteInfo? route;
  final VehicleInfo? vehicle;
  final LocationInfo? latestLocation;

  DashboardModel({
    required this.user,
    this.route,
    this.vehicle,
    this.latestLocation,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: json['user'],
      route: json['route'] != null ? RouteInfo.fromJson(json['route']) : null,
      vehicle: json['vehicle'] != null ? VehicleInfo.fromJson(json['vehicle']) : null,
      latestLocation: json['latest_location'] != null
          ? LocationInfo.fromJson(json['latest_location'])
          : null,
    );
  }
}