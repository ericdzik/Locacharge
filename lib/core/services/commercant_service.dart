// lib/core/services/commercant_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/core/models/commercant_model.dart';

class CommercantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'commercants';

  Future<CommercantModel?> getCommercantByUserId(String userId) async {
    // ... (existant)
    try {
      DocumentSnapshot doc = await _firestore.collection(_collectionPath).doc(userId).get();
      if (doc.exists) {
        return CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erreur CommercantService - getCommercantByUserId: $e");
      return null;
    }
  }

  Future<void> updateDisponibilite(String commercantId, StatutDisponibilite statut) async {
    // ... (existant)
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).update({
        'statutDisponibilite': statut.toString(),
      });
    } catch (e) {
      print("Erreur CommercantService - updateDisponibilite: $e");
      rethrow;
    }
  }

  Future<void> updateCommercantInfo(String commercantId, Map<String, dynamic> data) async {
    // ... (existant)
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).update(data);
    } catch (e) {
      print("Erreur CommercantService - updateCommercantInfo: $e");
      rethrow;
    }
  }

  // MODIFIÉ: createCommercant pour prendre un CommercantModel et utiliser son ID pour le document
  Future<void> createOrUpdateCommercant(CommercantModel commercant) async {
    try {
      // L'ID du CommercantModel sera l'ID du document Firestore.
      // Cela suppose que commercant.id est l'UID de l'utilisateur Firebase associé.
      await _firestore.collection(_collectionPath).doc(commercant.id).set(commercant.toMap());
    } catch (e) {
      print("Erreur CommercantService - createOrUpdateCommercant: $e");
      rethrow;
    }
  }

  // NOUVEAU: Récupérer tous les commerçants
  Stream<List<CommercantModel>> getAllCommercantsStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      try {
        return snapshot.docs.map((doc) => CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
      } catch (e) {
        print("Erreur CommercantService - getAllCommercantsStream: $e");
        return []; // Retourne une liste vide en cas d'erreur de parsing
      }
    });
  }

  // NOUVEAU: Supprimer un commerçant par son ID
  Future<void> deleteCommercant(String commercantId) async {
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).delete();
    } catch (e) {
      print("Erreur CommercantService - deleteCommercant: $e");
      rethrow;
    }
  }
}
