import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _storageService.isLoggedIn();
    if (isLoggedIn) {
      try {
        final userData = await _apiService.getMe();
        _user = UserModel.fromJson(userData);
        _state = AuthState.authenticated;
      } catch (_) {
        await _storageService.clearAll();
        _state = AuthState.unauthenticated;
      }
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      final token = response['access_token'];
      final userId = response['user_id'];
      final uname = response['username'];

      await _storageService.saveToken(token);
      await _storageService.saveUserInfo(userId, uname);

      final userData = await _apiService.getMe();
      _user = UserModel.fromJson(userData);

      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseError(e);
      _state = AuthState.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('401')) return 'Invalid username or password';
    if (msg.contains('403')) return 'Account is inactive';
    if (msg.contains('SocketException')) return 'No internet connection';
    return 'Login failed. Please try again.';
  }
}