class ESIM {
  final String id;
  final String userId;
  final String provider;
  final String plan;
  final String status;
  final String iccid;
  final DateTime createdAt;

  ESIM({
    required this.id,
    required this.userId,
    required this.provider,
    required this.plan,
    required this.status,
    required this.iccid,
    required this.createdAt,
  });

  bool get isActive => status == 'active';

  factory ESIM.fromJson(Map<String, dynamic> json) {
    return ESIM(
      id: json['id'],
      userId: json['userId'],
      provider: json['provider'],
      plan: json['plan'],
      status: json['status'],
      iccid: json['iccid'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ESIMPlan {
  final String id;
  final String provider;
  final String country;
  final String countryCode;
  final int dataGb;
  final int days;
  final double price;

  ESIMPlan({
    required this.id,
    required this.provider,
    required this.country,
    required this.countryCode,
    required this.dataGb,
    required this.days,
    required this.price,
  });

  factory ESIMPlan.fromJson(Map<String, dynamic> json) {
    return ESIMPlan(
      id: json['id'],
      provider: json['provider'],
      country: json['country'],
      countryCode: json['countryCode'],
      dataGb: json['dataGb'],
      days: json['days'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class ESIMProvider {
  final String id;
  final String name;
  final String logo;
  final String description;

  ESIMProvider({
    required this.id,
    required this.name,
    required this.logo,
    required this.description,
  });

  factory ESIMProvider.fromJson(Map<String, dynamic> json) {
    return ESIMProvider(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      description: json['description'],
    );
  }
}
