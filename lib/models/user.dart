class User {
  final String username;
  final String email;
  final String password;
  final String? name;
  final int? age;
  final double? weight;
  final double? height;

  User({
    required this.username,
    required this.email,
    required this.password,
    this.name,
    this.age,
    this.weight,
    this.height,
  });

  // Convert User object to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }

  // Create User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'],
      age: json['age'],
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }

  // Create a copy of User with updated fields
  User copyWith({
    String? username,
    String? email,
    String? password,
    String? name,
    int? age,
    double? weight,
    double? height,
  }) {
    return User(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
    );
  }

  @override
  String toString() {
    return 'User(username: $username, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.username == username &&
        other.email == email &&
        other.password == password;
  }

  @override
  int get hashCode {
    return username.hashCode ^ email.hashCode ^ password.hashCode;
  }
}
