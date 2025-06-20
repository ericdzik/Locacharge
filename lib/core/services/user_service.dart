// lib/core/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/core/models/user_model.dart'; // UserModel créé précédemment
import 'package:locacharge/core/models/role_enum.dart'; // UserRole créé précédemment

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'users'; // Nom de la collection Firestore pour les utilisateurs

  // Récupérer un utilisateur par son ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionPath).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erreur UserService - getUserById: $e");
      return null;
    }
  }

  // Créer ou mettre à jour un utilisateur dans Firestore (par exemple après l'inscription)
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collectionPath).doc(user.id).set(user.toMap());
    } catch (e) {
      print("Erreur UserService - createUser: $e");
      rethrow;
    }
  }

  // Mettre à jour le rôle d'un utilisateur (potentiellement utile pour l'admin)
  Future<void> updateUserRole(String userId, UserRole role) async {
    try {
      await _firestore.collection(_collectionPath).doc(userId).update({'role': role.toString()});
    } catch (e) {
      print("Erreur UserService - updateUserRole: $e");
      rethrow;
    }
  }
}
