import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/tracking_provider.dart';
import '../models/gps_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tracking = context.read<TrackingProvider>();
      tracking.loadDashboard().then((_) => tracking.startPolling());
    });
  }

  @override
  void dispose() {
    context.read<TrackingProvider>().stopPolling();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    context.read<TrackingProvider>().stopPolling();
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('GPS Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TrackingProvider>().loadDashboard(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, tracking, _) {
          if (tracking.isLoading && tracking.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tracking.state == TrackingState.error &&
              tracking.dashboard == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(tracking.errorMessage ?? 'Something went wrong'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: tracking.loadDashboard,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (tracking.dashboard == null) {
            return const Center(child: Text('No data available'));
          }
          return RefreshIndicator(
            onRefresh: tracking.loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcomeCard(tracking.dashboard!),
                const SizedBox(height: 16),
                _buildRouteCard(tracking.dashboard!.route),
                const SizedBox(height: 16),
                _buildVehicleCard(tracking.dashboard!.vehicle),
                const SizedBox(height: 16),
                _buildLocationCard(tracking.dashboard!.latestLocation),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(DashboardModel dashboard) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1565C0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text(
                  dashboard.user['full_name'] ?? dashboard.user['username'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(RouteInfo? route) {
    if (route == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No route assigned'),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                const Text('My Route',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Chip(
                  label: Text(route.routeCode),
                  backgroundColor: Colors.blue.shade50,
                  labelStyle: const TextStyle(color: Color(0xFF1565C0)),
                ),
              ],
            ),
            const Divider(),
            Text(route.routeName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.trip_origin, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(route.startLocation),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(route.endLocation),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(VehicleInfo? vehicle) {
    if (vehicle == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No vehicle assigned'),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.directions_bus, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                const Text('My Vehicle',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: vehicle.isActive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: vehicle.isActive ? Colors.green : Colors.red),
                  ),
                  child: Text(
                    vehicle.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: vehicle.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildRow('Vehicle ID', vehicle.vehicleId),
            const SizedBox(height: 8),
            _buildRow('Number', vehicle.vehicleNumber),
            if (vehicle.model != null) ...[
              const SizedBox(height: 8),
              _buildRow('Model', vehicle.model!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLocationCard(LocationInfo? location) {
    if (location == null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.location_off, color: Colors.grey),
              SizedBox(width: 8),
              Text('No GPS data available yet'),
            ],
          ),
        ),
      );
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gps_fixed, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                const Text('Live Location',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text(
                  DateFormat('HH:mm:ss').format(location.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Divider(),
            _buildRow('Latitude', location.latitude.toStringAsFixed(6)),
            const SizedBox(height: 8),
            _buildRow('Longitude', location.longitude.toStringAsFixed(6)),
            if (location.speed != null) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.speed, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '${location.speed!.toStringAsFixed(1)} km/h',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}