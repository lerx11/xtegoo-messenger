import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../models/marketplace.dart';

class MarketplaceService {
  final ApiService _api;

  MarketplaceService(this._api);

  Future<List<Product>> getProducts({String? category, String? search}) async {
    final response = await _api.get('/marketplace/search', queryParameters: {
      if (category != null) 'category': category,
      if (search != null) 'q': search,
    });
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProduct(String productId) async {
    final response = await _api.get('/marketplace/products/$productId');
    return Product.fromJson(response.data);
  }

  Future<List<Service>> getServices({String? category}) async {
    final response = await _api.get('/marketplace/services', queryParameters: {
      if (category != null) 'category': category,
    });
    return (response.data as List).map((e) => Service.fromJson(e)).toList();
  }

  Future<Service> getService(String serviceId) async {
    final response = await _api.get('/marketplace/services/$serviceId');
    return Service.fromJson(response.data);
  }

  Future<List<String>> getCategories() async {
    final response = await _api.get('/marketplace/categories');
    return List<String>.from(response.data);
  }

  Future<Order> createOrder(String productId) async {
    final response = await _api.post('/marketplace/orders', data: {
      'productId': productId,
    });
    return Order.fromJson(response.data);
  }

  Future<List<Order>> getMyOrders() async {
    final response = await _api.get('/marketplace/orders/my');
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final apiService = ApiService();
  return MarketplaceService(apiService);
});
