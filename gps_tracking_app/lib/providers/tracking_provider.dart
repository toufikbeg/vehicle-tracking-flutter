import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gps_model.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

enum TrackingState { initial, loading, loaded, error }

class TrackingProvider extends ChangeNotifier {
  TrackingState _state = TrackingState.initial;
  DashboardModel? _dashboard;
  String? _errorMessage;
  Timer? _pollingTimer;

  TrackingState get state => _state;
  DashboardModel? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == TrackingState.loading;

  final ApiService _apiService = ApiService();

  Future<void> loadDashboard() async {
    _state = TrackingState.loading;
    notifyListeners();

    try {
      final data = await _apiService.getDashboard();
      _dashboard = DashboardModel.fromJson(data);
      _state = TrackingState.loaded;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _parseError(e);
      _state = TrackingState.error;
    }
    notifyListeners();
  }

  Future<void> refreshLocation() async {
    try {
      final data = await _apiService.getCurrentLocation();
      if (_dashboard != null) {
        final newLocation = LocationInfo(
          latitude: (data['latitude'] as num).toDouble(),
          longitude: (data['longitude'] as num).toDouble(),
          speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
          heading: data['heading'] != null ? (data['heading'] as num).toDouble() : null,
          timestamp: DateTime.parse(data['timestamp']),
        );
        _dashboard = DashboardModel(
          user: _dashboard!.user,
          route: _dashboard!.route,
          vehicle: _dashboard!.vehicle,
          latestLocation: newLocation,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: AppConfig.gpsPollingInterval),
      (_) => refreshLocation(),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('403')) return 'No route or vehicle assigned';
    if (msg.contains('404')) return 'GPS data not available yet';
    if (msg.contains('SocketException')) return 'No internet connection';
    return 'Failed to load tracking data';
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}