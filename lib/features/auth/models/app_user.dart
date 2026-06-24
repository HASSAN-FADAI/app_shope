class AppUser {
  final String id;
  final String email;
  final String role;

  const AppUser({required this.id, required this.email, this.role = 'user'});

  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'role': role};
}
