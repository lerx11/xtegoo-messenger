import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/user.dart';

class UserService {
  final ApiService _api;

  UserService(this._api);

  Future<User> getMe() async {
    final response = await _api.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<User> getById(String userId) async {
    final response = await _api.get('/users/$userId');
    return User.fromJson(response.data);
  }

  Future<List<User>> search(String query) async {
    final response = await _api.get('/users/search', queryParameters: {'q': query});
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<bool> checkUsername(String username) async {
    final response = await _api.get('/users/check-username/$username');
    return response.data['available'] == true;
  }

  Future<User> updateUsername(String username) async {
    final response = await _api.put('/users/update-username', data: {'username': username});
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.put('/users/update-profile', data: data);
    return User.fromJson(response.data);
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ApiService();
  return UserService(apiService);
});
