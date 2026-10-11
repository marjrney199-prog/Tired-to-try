class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final bool isActive;
  bool get isGuest => email.isEmpty;

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'].toString(),
        name: map['name']?.toString() ?? 'Utilizador',
        email: map['email']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
            DateTime.now(),
        isActive: (map['is_active'] ?? 1) == 1 || map['is_active'] == true,
      );

  Map<String, dynamic> toPublicMap() => {
        'id': id,
        'name': name,
        'email': email,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive ? 1 : 0,
      };
}
