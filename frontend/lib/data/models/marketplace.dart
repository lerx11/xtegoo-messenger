import 'user.dart';

class Product {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double price;
  final List<String> images;
  final String? category;
  final DateTime createdAt;
  final User? user;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.price,
    this.images = const [],
    this.category,
    required this.createdAt,
    this.user,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      images: List<String>.from(json['images'] ?? []),
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Service {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final double price;
  final int duration;
  final String? category;
  final DateTime createdAt;
  final User? user;

  Service({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.price,
    required this.duration,
    this.category,
    required this.createdAt,
    this.user,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      duration: json['duration'] ?? 0,
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class Order {
  final String id;
  final String buyerId;
  final String productId;
  final String status;
  final DateTime createdAt;
  final Product? product;

  Order({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.status,
    required this.createdAt,
    this.product,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      buyerId: json['buyerId'],
      productId: json['productId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
    );
  }
}

class Booking {
  final String id;
  final String serviceId;
  final String clientId;
  final DateTime date;
  final String status;
  final DateTime createdAt;
  final Service? service;
  final User? client;

  Booking({
    required this.id,
    required this.serviceId,
    required this.clientId,
    required this.date,
    required this.status,
    required this.createdAt,
    this.service,
    this.client,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      serviceId: json['serviceId'],
      clientId: json['clientId'],
      date: DateTime.parse(json['date']),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
      service: json['service'] != null ? Service.fromJson(json['service']) : null,
      client: json['client'] != null ? User.fromJson(json['client']) : null,
    );
  }
}
