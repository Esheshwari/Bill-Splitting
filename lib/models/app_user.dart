class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String avatarUrl;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

