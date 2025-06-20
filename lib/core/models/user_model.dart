// lib/core/models/user_model.dart
import 'package:locacharge/core/models/role_enum.dart'; // Assurez-vous que ce fichier existe

class UserModel {
  final String id;
  final String? email;
  final String? nomComplet;
  final String? telephone;
  final UserRole role;
  // Ajoutez d'autres champs si nécessaire (ex: photoUrl, préférences)

  UserModel({
    required this.id,
    this.email,
    this.nomComplet,
    this.telephone,
    this.role = UserRole.client,
  });

  // Méthode pour la sérialisation/désérialisation Firestore
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] as String?,
      nomComplet: data['nomComplet'] as String?,
      telephone: data['telephone'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == data['role'],
        orElse: () => UserRole.client,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nomComplet': nomComplet,
      'telephone': telephone,
      'role': role.toString(),
    };
  }
}
