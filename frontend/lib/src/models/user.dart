/// Represents the logged-in user / client.
/// Maps to the backend Client entity.
class User {
  final int id;
  final String nom;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.nom,
    required this.email,
    this.role = 'CLIENT',
  });

  /// Creates a User from JSON returned by login/register API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CLIENT',
    );
  }

  /// Converts this User to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'role': role,
    };
  }
}
