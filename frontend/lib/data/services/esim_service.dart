import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/esim.dart';

class ESIMService {
  final ApiService _api;

  ESIMService(this._api);

  Future<List<ESIMProvider>> getProviders() async {
    final response = await _api.get('/esim/providers');
    return (response.data as List).map((e) => ESIMProvider.fromJson(e)).toList();
  }

  Future<List<ESIMPlan>> getPlans({String? country}) async {
    final response = await _api.get('/esim/plans', queryParameters: {
      if (country != null) 'country': country,
    });
    return (response.data as List).map((e) => ESIMPlan.fromJson(e)).toList();
  }

  Future<ESIM> purchaseESIM(String planId) async {
    final response = await _api.post('/esim/purchase', data: {'planId': planId});
    return ESIM.fromJson(response.data);
  }

  Future<List<ESIM>> getMyESIMs() async {
    final response = await _api.get('/esim/my');
    return (response.data as List).map((e) => ESIM.fromJson(e)).toList();
  }
}

final esimServiceProvider = Provider<ESIMService>((ref) {
  final apiService = ApiService();
  return ESIMService(apiService);
});
