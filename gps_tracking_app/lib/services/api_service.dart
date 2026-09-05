import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: FormData.fromMap({
        'username': username,
        'password': password,
      }),
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _dio.get('/auth/me');
    return response.data;
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _dio.get('/gps/dashboard');
    return response.data;
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    final response = await _dio.get('/gps/current-location');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyRoute() async {
    final response = await _dio.get('/routes/my-route');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyVehicle() async {
    final response = await _dio.get('/vehicles/my-vehicle');
    return response.data;
  }
}