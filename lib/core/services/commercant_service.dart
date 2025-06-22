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

  static final CommercantService _instance = CommercantService._internal();
  factory CommercantService() => _instance;
  CommercantService._internal();

  // Données mockées pour les produits
  final List<ProduitModel> _produitsMock = [
    ProduitModel(
      id: '1',
      nom: 'Recharge MTN 1000 FCFA',
      description: 'Recharge téléphonique MTN de 1000 FCFA',
      type: TypeProduit.rechargeTelephonique,
      prix: 1000.0,
      statut: StatutProduit.disponible,
      operateurs: ['MTN'],
      dateCreation: DateTime.now().subtract(const Duration(days: 30)),
      dateModification: DateTime.now(),
    ),
    ProduitModel(
      id: '2',
      nom: 'Recharge Orange 500 FCFA',
      description: 'Recharge téléphonique Orange de 500 FCFA',
      type: TypeProduit.rechargeTelephonique,
      prix: 500.0,
      statut: StatutProduit.disponible,
      operateurs: ['Orange'],
      dateCreation: DateTime.now().subtract(const Duration(days: 25)),
      dateModification: DateTime.now(),
    ),
    ProduitModel(
      id: '3',
      nom: 'Forfait Internet MTN 1GB',
      description: 'Forfait Internet MTN 1GB valable 30 jours',
      type: TypeProduit.forfaitInternet,
      prix: 2500.0,
      statut: StatutProduit.disponible,
      operateurs: ['MTN'],
      dateCreation: DateTime.now().subtract(const Duration(days: 20)),
      dateModification: DateTime.now(),
    ),
    ProduitModel(
      id: '4',
      nom: 'Forfait Internet Orange 2GB',
      description: 'Forfait Internet Orange 2GB valable 30 jours',
      type: TypeProduit.forfaitInternet,
      prix: 3000.0,
      statut: StatutProduit.epuise,
      operateurs: ['Orange'],
      dateCreation: DateTime.now().subtract(const Duration(days: 15)),
      dateModification: DateTime.now(),
    ),
    ProduitModel(
      id: '5',
      nom: 'Transfert Mobile Money MTN',
      description: 'Service de transfert d\'argent via Mobile Money MTN',
      type: TypeProduit.mobileMoney,
      prix: 0.0,
      statut: StatutProduit.disponible,
      operateurs: ['MTN'],
      dateCreation: DateTime.now().subtract(const Duration(days: 10)),
      dateModification: DateTime.now(),
    ),
    ProduitModel(
      id: '6',
      nom: 'Carte Prépayée Moov 1000 FCFA',
      description: 'Carte prépayée Moov avec 1000 FCFA de crédit',
      type: TypeProduit.cartesPrepayees,
      prix: 1000.0,
      statut: StatutProduit.disponible,
      operateurs: ['Moov'],
      dateCreation: DateTime.now().subtract(const Duration(days: 5)),
      dateModification: DateTime.now(),
    ),
  ];

  // Données mockées pour les commerçants
  List<CommercantModel> _commercantsMock = [];

  void _initializeMockData() {
    if (_commercantsMock.isNotEmpty) return;

    _commercantsMock = [
      CommercantModel(
        id: '1',
        nom: 'Boutique Chez Ali',
        description:
            'Boutique spécialisée dans les recharges téléphoniques et services numériques',
        localisation: LocalisationModel(
            latitude: 5.3550,
            longitude: -4.0200,
            adresse: "Treichville Centre, Rue du Commerce"),
        horaires: [
          HoraireModel(jour: "Lundi", ouverture: "08:00", fermeture: "19:00"),
          HoraireModel(jour: "Mardi", ouverture: "08:00", fermeture: "19:00"),
          HoraireModel(
              jour: "Mercredi", ouverture: "08:00", fermeture: "19:00"),
          HoraireModel(jour: "Jeudi", ouverture: "08:00", fermeture: "19:00"),
          HoraireModel(
              jour: "Vendredi", ouverture: "08:00", fermeture: "19:00"),
          HoraireModel(jour: "Samedi", ouverture: "09:00", fermeture: "17:00"),
        ],
        statutDisponibilite: StatutDisponibilite.disponible,
        telephone: "0102030405",
        email: "ali@boutique.com",
        typeCommercant: TypeCommercant.boutique,
        produits: _produitsMock
            .take(3)
            .toList(), // MTN recharge, Orange recharge, MTN internet
        services: [
          'Mobile Money MTN',
          'Mobile Money Orange',
          'Transfert d\'argent'
        ],
        note: 4.5,
        nombreEvaluations: 127,
        dateCreation: DateTime.now().subtract(const Duration(days: 365)),
        dateModification: DateTime.now(),
      ),
      CommercantModel(
        id: '2',
        nom: 'Station Service Shell Cocody',
        description: 'Station service avec kiosque de services numériques',
        localisation: LocalisationModel(
            latitude: 5.3600,
            longitude: -3.9900,
            adresse: "Cocody Danga, Boulevard Latrille"),
        horaires: [
          HoraireModel(
              jour: "Lundi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Mardi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Mercredi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Jeudi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Vendredi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Samedi",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
          HoraireModel(
              jour: "Dimanche",
              ouverture: "00:00",
              fermeture: "23:59",
              estOuvert24h: true),
        ],
        statutDisponibilite: StatutDisponibilite.epuise,
        telephone: "0506070809",
        email: "contact@shell-cocody.com",
        typeCommercant: TypeCommercant.stationService,
        produits:
            _produitsMock.take(2).toList(), // MTN recharge, Orange recharge
        services: ['Mobile Money MTN', 'Mobile Money Orange'],
        note: 4.2,
        nombreEvaluations: 89,
        dateCreation: DateTime.now().subtract(const Duration(days: 300)),
        dateModification: DateTime.now(),
      ),
      CommercantModel(
        id: '3',
        nom: 'Le Kiosque Orange Money Marcory',
        description: 'Kiosque officiel Orange Money pour tous services Orange',
        localisation: LocalisationModel(
            latitude: 5.3480,
            longitude: -4.0280,
            adresse: "Marcory Remblais, Avenue des Banques"),
        horaires: [
          HoraireModel(jour: "Lundi", ouverture: "08:00", fermeture: "18:00"),
          HoraireModel(jour: "Mardi", ouverture: "08:00", fermeture: "18:00"),
          HoraireModel(
              jour: "Mercredi", ouverture: "08:00", fermeture: "18:00"),
          HoraireModel(jour: "Jeudi", ouverture: "08:00", fermeture: "18:00"),
          HoraireModel(
              jour: "Vendredi", ouverture: "08:00", fermeture: "18:00"),
          HoraireModel(jour: "Samedi", ouverture: "09:00", fermeture: "16:00"),
        ],
        statutDisponibilite: StatutDisponibilite.disponible,
        telephone: "0708090001",
        email: "marcory@orangemoney.ci",
        typeCommercant: TypeCommercant.kiosque,
        produits: _produitsMock
            .where((p) => p.operateurs.contains('Orange'))
            .toList(),
        services: [
          'Mobile Money Orange',
          'Transfert d\'argent',
          'Paiement de factures'
        ],
        note: 4.8,
        nombreEvaluations: 234,
        dateCreation: DateTime.now().subtract(const Duration(days: 200)),
        dateModification: DateTime.now(),
      ),
      CommercantModel(
        id: '4',
        nom: 'Pharmacie de la Savane',
        description: 'Pharmacie avec services de recharges et Mobile Money',
        localisation: LocalisationModel(
            latitude: 5.3510,
            longitude: -4.0150,
            adresse: "Treichville Savane, Rue des Pharmacies"),
        horaires: [
          HoraireModel(jour: "Lundi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(jour: "Mardi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(
              jour: "Mercredi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(jour: "Jeudi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(
              jour: "Vendredi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(jour: "Samedi", ouverture: "09:00", fermeture: "20:00"),
          HoraireModel(
              jour: "Dimanche", ouverture: "10:00", fermeture: "18:00"),
        ],
        statutDisponibilite: StatutDisponibilite.disponible,
        telephone: "0700000001",
        email: "contact@pharmacie-savane.ci",
        typeCommercant: TypeCommercant.pharmacie,
        produits: _produitsMock.take(4).toList(), // Tous sauf Moov
        services: [
          'Mobile Money MTN',
          'Mobile Money Orange',
          'Paiement de factures'
        ],
        note: 4.6,
        nombreEvaluations: 156,
        dateCreation: DateTime.now().subtract(const Duration(days: 150)),
        dateModification: DateTime.now(),
      ),
      CommercantModel(
        id: '5',
        nom: 'Super Marché Cocody Centre',
        description: 'Supermarché avec section services numériques',
        localisation: LocalisationModel(
            latitude: 5.3650,
            longitude: -3.9850,
            adresse: "Cocody Centre Commercial, 2ème Plateau"),
        horaires: [
          HoraireModel(jour: "Lundi", ouverture: "07:00", fermeture: "21:00"),
          HoraireModel(jour: "Mardi", ouverture: "07:00", fermeture: "21:00"),
          HoraireModel(
              jour: "Mercredi", ouverture: "07:00", fermeture: "21:00"),
          HoraireModel(jour: "Jeudi", ouverture: "07:00", fermeture: "21:00"),
          HoraireModel(
              jour: "Vendredi", ouverture: "07:00", fermeture: "21:00"),
          HoraireModel(jour: "Samedi", ouverture: "08:00", fermeture: "22:00"),
          HoraireModel(
              jour: "Dimanche", ouverture: "09:00", fermeture: "20:00"),
        ],
        statutDisponibilite: StatutDisponibilite.disponible,
        telephone: "0800000002",
        email: "info@supermarche-cocody.ci",
        typeCommercant: TypeCommercant.supermarche,
        produits: _produitsMock, // Tous les produits
        services: [
          'Mobile Money MTN',
          'Mobile Money Orange',
          'Mobile Money Moov',
          'Transfert d\'argent',
          'Paiement de factures'
        ],
        note: 4.3,
        nombreEvaluations: 445,
        dateCreation: DateTime.now().subtract(const Duration(days: 100)),
        dateModification: DateTime.now(),
      ),
    ];
  }

  Future<CommercantModel?> getCommercantByUserId(String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .where('userId', isEqualTo: userId)
          .get();
      if (doc.docs.isNotEmpty) {
        return CommercantModel.fromMap(
            doc.docs.first.id, doc.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du commerçant: $e');
      return null;
    }
  }

  Future<void> updateDisponibilite(
      String commercantId, StatutDisponibilite statut) async {
    try {
      await _firestore.collection(_collectionPath).doc(commercantId).update({
        'statutDisponibilite': statut.toString(),
      });
    } catch (e) {
      print("Erreur CommercantService - updateDisponibilite: $e");
      rethrow;
    }
  }

  Future<void> updateCommercantInfo(
      String commercantId, Map<String, dynamic> data) async {
    try {
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
          .doc(commercant.id)
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
        return []; // Retourne une liste vide en cas d'erreur de parsing
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
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 500));
    return _commercantsMock;
  }

  Future<CommercantModel?> getCommercantById(String id) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _commercantsMock.firstWhere((c) => c.id == id);
    } catch (e) {
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
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    List<CommercantModel> filtered = _commercantsMock;

    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.nom.toLowerCase().contains(query.toLowerCase()) ||
            (c.description?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (c.localisation.adresse
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false);
      }).toList();
    }

    if (statut != null) {
      filtered =
          filtered.where((c) => c.statutDisponibilite == statut).toList();
    }

    if (estOuvert != null) {
      filtered =
          filtered.where((c) => c.estOuvertMaintenant == estOuvert).toList();
    }

    if (typesProduit != null && typesProduit.isNotEmpty) {
      filtered = filtered.where((c) {
        return typesProduit.every(
            (type) => c.produits.any((p) => p.type == type && p.estDisponible));
      }).toList();
    }

    if (services != null && services.isNotEmpty) {
      filtered = filtered.where((c) {
        return services.every((service) => c.services
            .any((s) => s.toLowerCase().contains(service.toLowerCase())));
      }).toList();
    }

    if (operateur != null && operateur.isNotEmpty) {
      filtered = filtered
          .where((c) => c.produits
              .any((p) => p.operateurs.contains(operateur) && p.estDisponible))
          .toList();
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
  }

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

  Future<void> updateCommercant(CommercantModel commercant) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _commercantsMock.indexWhere((c) => c.id == commercant.id);
    if (index != -1) {
      _commercantsMock[index] = commercant.copyWith(
        dateModification: DateTime.now(),
      );
    } else {
      throw Exception('Commerçant non trouvé');
    }
  }

  Future<bool> addCommercant(CommercantModel commercant) async {
    _initializeMockData();
    await Future.delayed(const Duration(milliseconds: 600));

    _commercantsMock.add(commercant);
    return true;
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
