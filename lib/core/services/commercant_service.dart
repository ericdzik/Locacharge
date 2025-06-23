// lib/core/services/commercant_service.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/produit_model.dart';
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';

class CommercantService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'commercants';

  // static final CommercantService _instance = CommercantService._internal();
  // factory CommercantService() => _instance;
  // CommercantService._internal();
  // Le constructeur par défaut est suffisant si le service est instancié directement.

  // Les données mockées et _initializeMockData() sont supprimées.

  Future<CommercantModel?> getCommercantByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId) // Supposant un champ 'userId' dans le document commerçant
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Erreur CommercantService - getCommercantByUserId: $e');
      return null;
    }
  }

  Future<void> updateDisponibilite(
      String commercantId, StatutDisponibilite statut) async {
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).update({
        'statutDisponibilite': statut.toString().split('.').last, // Sauvegarde la string de l'enum
      });
    } catch (e) {
      print("Erreur CommercantService - updateDisponibilite: $e");
      rethrow;
    }
  }

  Future<void> updateCommercantInfo(
      String commercantId, Map<String, dynamic> data) async {
    try {
      // Assurez-vous que les dates sont converties en Timestamps ou ISO strings si nécessaire
      // avant d'appeler cette méthode, ou gérez-le ici.
      // Par exemple, si 'dateModification' est dans data et est un DateTime:
      // data['dateModification'] = Timestamp.fromDate(data['dateModification']);
      await _firestore
          .collection(_collectionPath)
          .doc(commercantId)
          .update(data);
    } catch (e) {
      print("Erreur CommercantService - updateCommercantInfo: $e");
      rethrow;
    }
  }

  Future<void> createOrUpdateCommercant(CommercantModel commercant) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(commercant.id) // Utilise l'ID du commerçant comme ID de document
          .set(commercant.toMap());
    } catch (e) {
      print("Erreur CommercantService - createOrUpdateCommercant: $e");
      rethrow;
    }
  }

  Stream<List<CommercantModel>> getAllCommercantsStream() {
    return _firestore.collection(_collectionPath).snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => CommercantModel.fromMap(
                doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Erreur CommercantService - getAllCommercantsStream: $e");
        return [];
      }
    });
  }

  Future<void> deleteCommercant(String commercantId) async {
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).delete();
    } catch (e) {
      print("Erreur CommercantService - deleteCommercant: $e");
      rethrow;
    }
  }

  Future<List<CommercantModel>> getAllCommercants() async {
    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      return snapshot.docs
          .map((doc) => CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur CommercantService - getAllCommercants (Firestore): $e");
      return [];
    }
  }

  Future<CommercantModel?> getCommercantById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        return CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Erreur CommercantService - getCommercantById (Firestore): $e");
      return null;
    }
  }

  Future<List<CommercantModel>> searchCommercants({
    String? query,
    StatutDisponibilite? statut,
    bool? estOuvert,
    List<TypeProduit>? typesProduit,
    List<String>? services,
    String? operateur,
    double? distanceMax,
    LatLng? userLocation,
  }) async {
    try {
      Query<Map<String, dynamic>> firestoreQuery = _firestore.collection(_collectionPath);

      // TODO: Ajouter des filtres Firestore simples si possible (ex: estActif == true)
      // Exemple: firestoreQuery = firestoreQuery.where('estActif', isEqualTo: true);
      // Note: Les requêtes Firestore complexes avec multiples 'array-contains' ou 'OR' sur différents champs
      // ne sont pas supportées directement. La recherche textuelle partielle non plus.
      // Pour l'instant, on récupère une base de documents et on filtre en local.

      // Si une query textuelle est fournie, et si on avait un champ 'keywords' (liste de mots-clés)
      // dans Firestore, on pourrait tenter un 'array-contains' pour un mot-clé.
      // if (query != null && query.isNotEmpty) {
      //   firestoreQuery = firestoreQuery.where('keywords', arrayContains: query.toLowerCase());
      // }
      // Pour une recherche textuelle plus robuste, des solutions comme Algolia sont recommandées.

      final snapshot = await firestoreQuery.get();
      List<CommercantModel> allCommercants = snapshot.docs
          .map((doc) => CommercantModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      List<CommercantModel> filtered = allCommercants;

      if (query != null && query.isNotEmpty) {
        String lowerQuery = query.toLowerCase();
        filtered = filtered.where((c) {
          return c.nom.toLowerCase().contains(lowerQuery) ||
              (c.description?.toLowerCase().contains(lowerQuery) ?? false) ||
              (c.localisation.adresse?.toLowerCase().contains(lowerQuery) ?? false) ||
              c.services.any((s) => s.toLowerCase().contains(lowerQuery)) ||
              c.produits.any((p) => p.nom.toLowerCase().contains(lowerQuery));
        }).toList();
      }

      if (statut != null) {
        filtered = filtered.where((c) => c.statutDisponibilite == statut).toList();
      }

      if (estOuvert != null) {
        // Le calcul de estOuvertMaintenant se fait via le getter du modèle, donc filtrage local.
        filtered = filtered.where((c) => c.estOuvertMaintenant == estOuvert).toList();
      }

      if (typesProduit != null && typesProduit.isNotEmpty) {
        filtered = filtered.where((c) {
          return typesProduit.every(
              (type) => c.produits.any((p) => p.type == type && p.estDisponible));
        }).toList();
      }

      if (services != null && services.isNotEmpty) {
        filtered = filtered.where((c) {
          return services.every((serviceName) =>
              c.services.any((s) => s.toLowerCase().contains(serviceName.toLowerCase())));
        }).toList();
      }

      if (operateur != null && operateur.isNotEmpty) {
        filtered = filtered.where((c) =>
            c.produits.any((p) => p.operateurs.contains(operateur) && p.estDisponible)
        ).toList();
      }

      if (distanceMax != null && userLocation != null) {
        filtered = filtered.where((c) {
          final distance = _calculateDistance(
              userLocation.latitude,
              userLocation.longitude,
              c.localisation.latitude,
              c.localisation.longitude);
          return distance <= distanceMax;
        }).toList();
      }
      return filtered;
    } catch (e) {
      print("Erreur CommercantService - searchCommercants (Firestore): $e");
      return [];
    }
  }

  // TODO: Déplacer cette méthode dans un utilitaire de géolocalisation ou MapsService si réutilisée ailleurs.
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // en kilomètres

    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Les méthodes addCommercant et updateCommercant qui opéraient sur les mocks sont supprimées.
  // Les opérations d'écriture se font via createOrUpdateCommercant, updateCommercantInfo, etc.
  // qui utilisent déjà Firestore.

  // Future<void> updateCommercant(CommercantModel commercant) async {
  //   // Remplacé par createOrUpdateCommercant ou updateCommercantInfo
  // }

  // Future<bool> addCommercant(CommercantModel commercant) async {
  //   // Remplacé par createOrUpdateCommercant (qui fait un set, donc création si non existant)
  //   // ou une méthode createCommercant dédiée si on veut un ID auto-généré par Firestore.
  // }


  // Ces méthodes étaient déjà pour Firebase, s'assurer qu'elles sont cohérentes
  // avec les autres changements (par exemple, utilisation de commercant.id pour doc().set())
  Future<bool> createCommercant(CommercantModel commercant) async {
    try {
      // Si l'ID du commerçant est déjà défini et doit être utilisé comme ID de document:
      // await _firestore.collection(_collectionPath).doc(commercant.id).set(commercant.toMap());
      // Si l'ID doit être auto-généré par Firestore:
      DocumentReference docRef = await _firestore.collection(_collectionPath).add(commercant.toMapWithoutId());
      // Optionnel: mettre à jour le modèle avec l'ID généré si besoin immédiat.
      // commercant = commercant.copyWith(id: docRef.id);
      return true;
    } catch (e) {
      print('Erreur lors de la création du commerçant: $e');
      return false;
    }
  }

  Future<bool> updateCommercantFirebase(CommercantModel commercant) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(commercant.id)
          .update(commercant.toMap()); // toMap() devrait exclure l'ID si l'ID est l'ID du document
                                     // ou être idempotent si l'ID est inclus.
                                     // CommercantModel.toMap() n'inclut pas l'ID, c'est bien.
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du commerçant: $e');
      return false;
    }
  }

  Future<bool> deleteCommercantFirebase(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du commerçant: $e');
      return false;
    }
  }

  Future<bool> createCommercant(CommercantModel commercant) async {
    try {
      await _firestore.collection(_collectionPath).add(commercant.toMap());
      return true;
    } catch (e) {
      print('Erreur lors de la création du commerçant: $e');
      return false;
    }
  }

  Future<bool> updateCommercantFirebase(CommercantModel commercant) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(commercant.id)
          .update(commercant.toMap());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour du commerçant: $e');
      return false;
    }
  }

  Future<bool> deleteCommercantFirebase(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression du commerçant: $e');
      return false;
    }
  }
}
