import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'api_service.dart';
import '../models/user.dart';

class AuthService {
  final ApiService _api;
  final Box _authBox = Hive.box('auth');

  AuthService(this._api);

  Future<bool> sendCode(String phone) async {
    final response = await _api.post('/auth/send-code', data: {'phone': phone});
    return response.data['success'] == true;
  }

  Future<User?> verifyCode(String phone, String code) async {
    final response = await _api.post('/auth/verify-code', data: {
      'phone': phone,
      'code': code,
    });

    final data = response.data;
    _authBox.put('accessToken', data['accessToken']);
    _authBox.put('refreshToken', data['refreshToken']);

    return User.fromJson(data['user']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    _authBox.clear();
  }

  bool get isAuthenticated {
    return _authBox.get('accessToken') != null;
  }

  String? get accessToken {
    return _authBox.get('accessToken');
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ApiService();
  return AuthService(apiService);
});

final authStateProvider = StateProvider<bool>((ref) {
  return Hive.box('auth').get('accessToken') != null;
});

final currentUserProvider = StateProvider<User?>((ref) => null);
