class User {
  final String id;
  final String name;
  final String email;
  final String? mobile;
  final String? password;
  final String walletAddress;
  final double credits;
  final DateTime? memberSince;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.mobile,
    this.password,
    required this.walletAddress,
    required this.credits,
    this.memberSince,
    this.role = 'Project Developer',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      password: json['password'],
      walletAddress: json['walletAddress'],
      credits: json['credits'].toDouble(),
      memberSince: json['memberSince'] != null
          ? DateTime.parse(json['memberSince'])
          : null,
      role: json['role'] ?? 'Project Developer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'walletAddress': walletAddress,
      'credits': credits,
      'memberSince': memberSince?.toIso8601String(),
      'role': role,
    };
  }
}
