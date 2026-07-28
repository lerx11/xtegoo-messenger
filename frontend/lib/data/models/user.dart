class User {
  final String id;
  final String phone;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String? bio;
  final bool isBusiness;
  final String? businessName;
  final String? businessDesc;
  final String language;
  final DateTime createdAt;

  User({
    required this.id,
    required this.phone,
    this.username,
    this.firstName,
    this.lastName,
    this.avatar,
    this.bio,
    this.isBusiness = false,
    this.businessName,
    this.businessDesc,
    this.language = 'ru',
    required this.createdAt,
  });

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? username ?? phone;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      bio: json['bio'],
      isBusiness: json['isBusiness'] ?? false,
      businessName: json['businessName'],
      businessDesc: json['businessDesc'],
      language: json['language'] ?? 'ru',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'bio': bio,
      'isBusiness': isBusiness,
      'businessName': businessName,
      'businessDesc': businessDesc,
      'language': language,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
