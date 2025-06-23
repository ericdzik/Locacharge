// lib/core/models/commercant_model.dart
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/produit_model.dart';

enum StatutDisponibilite {
  disponible,
  epuise,
  inconnu,
}

enum TypeCommercant {
  boutique,
  kiosque,
  stationService,
  pharmacie,
  supermarche,
  autre
}

class CommercantModel {
  final String id;
  final String nom;
  final String? description;
  final LocalisationModel localisation;
  final List<HoraireModel> horaires;
  final String? imageUrl;
  final String? telephone;
  final String? email;
  final StatutDisponibilite statutDisponibilite; // Statut général du commerçant
  final bool estActif; // Pour l'administrateur (point actif/désactivé)
  final TypeCommercant typeCommercant;
  final List<ProduitModel> produits; // Produits numériques proposés
  final List<String> services; // Services proposés (Mobile Money, etc.)
  final double? note; // Note moyenne des utilisateurs
  final int nombreEvaluations; // Nombre d'évaluations
  final DateTime dateCreation;
  final DateTime dateModification;

  CommercantModel({
    required this.id,
    required this.nom,
    this.description,
    required this.localisation,
    required this.horaires,
    this.imageUrl,
    this.telephone,
    this.email,
    this.statutDisponibilite = StatutDisponibilite.inconnu,
    this.estActif = true,
    this.typeCommercant = TypeCommercant.autre,
    this.produits = const [],
    this.services = const [],
    this.note,
    this.nombreEvaluations = 0,
    required this.dateCreation,
    required this.dateModification,
  });

  // Méthode pour la sérialisation/désérialisation Firestore
  factory CommercantModel.fromMap(String id, Map<String, dynamic> data) {
    return CommercantModel(
      id: id,
      nom: data['nom'] as String,
      description: data['description'] as String?,
      localisation: LocalisationModel.fromMap(
          data['localisation'] as Map<String, dynamic>),
      horaires: (data['horaires'] as List<dynamic>? ?? [])
          .map((h) => HoraireModel.fromMap(h as Map<String, dynamic>))
          .toList(),
      imageUrl: data['imageUrl'] as String?,
      telephone: data['telephone'] as String?,
      email: data['email'] as String?,
      statutDisponibilite: StatutDisponibilite.values.firstWhere(
        (e) =>
            e.toString() ==
            'StatutDisponibilite.${data['statutDisponibilite']}',
        orElse: () => StatutDisponibilite.inconnu,
      ),
      estActif: data['estActif'] as bool? ?? true,
      typeCommercant: TypeCommercant.values.firstWhere(
        (e) => e.toString() == 'TypeCommercant.${data['typeCommercant']}',
        orElse: () => TypeCommercant.autre,
      ),
      produits: (data['produits'] as List<dynamic>? ?? [])
          .map((p) => ProduitModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      services: List<String>.from(data['services'] ?? []),
      note: data['note'] as double?,
      nombreEvaluations: data['nombreEvaluations'] as int? ?? 0,
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
      dateModification: (data['dateModification'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      if (description != null) 'description': description,
      'localisation': localisation.toMap(),
      'horaires': horaires.map((h) => h.toMap()).toList(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      'statutDisponibilite': statutDisponibilite.toString().split('.').last,
      'estActif': estActif,
      'typeCommercant': typeCommercant.toString().split('.').last,
      'produits': produits.map((p) => p.toJson()).toList(),
      'services': services,
      if (note != null) 'note': note,
      'nombreEvaluations': nombreEvaluations,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification.toIso8601String(),
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      'nom': nom,
      if (description != null) 'description': description,
      'localisation': localisation.toMap(),
      'horaires': horaires.map((h) => h.toMap()).toList(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (telephone != null) 'telephone': telephone,
      if (email != null) 'email': email,
      'statutDisponibilite': statutDisponibilite.toString().split('.').last,
      'estActif': estActif,
      'typeCommercant': typeCommercant.toString().split('.').last,
      'produits': produits.map((p) => p.toJson()).toList(),
      'services': services,
      if (note != null) 'note': note,
      'nombreEvaluations': nombreEvaluations,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification.toIso8601String(),
      // 'userId': id, // Supposant que l'ID du commerçant est l'UID de l'utilisateur pour la création via add()
    };
  }


  // Helper pour déterminer si le commerçant est ouvert (basé sur ses horaires)
  bool get estOuvertMaintenant {
    return estActuellementOuvert(
        horaires); // Utilise la fonction de horaire_model
  }

  // Helper pour obtenir les produits disponibles
  List<ProduitModel> get produitsDisponibles {
    return produits.where((p) => p.estDisponible).toList();
  }

  // Helper pour obtenir les produits par type
  List<ProduitModel> getProduitsParType(TypeProduit type) {
    return produits.where((p) => p.type == type).toList();
  }

  // Helper pour vérifier si le commerçant propose un service spécifique
  bool proposeService(String service) {
    return services.contains(service);
  }

  // Helper pour obtenir le statut global basé sur les produits
  StatutDisponibilite get statutGlobal {
    if (produits.isEmpty) return StatutDisponibilite.inconnu;

    final produitsDisponibles = produits.where((p) => p.estDisponible).length;
    final totalProduits = produits.length;

    if (produitsDisponibles == 0) return StatutDisponibilite.epuise;
    if (produitsDisponibles == totalProduits)
      return StatutDisponibilite.disponible;
    return StatutDisponibilite.disponible; // Partiellement disponible
  }

  String get typeCommercantDisplayName {
    switch (typeCommercant) {
      case TypeCommercant.boutique:
        return 'Boutique';
      case TypeCommercant.kiosque:
        return 'Kiosque';
      case TypeCommercant.stationService:
        return 'Station Service';
      case TypeCommercant.pharmacie:
        return 'Pharmacie';
      case TypeCommercant.supermarche:
        return 'Supermarché';
      case TypeCommercant.autre:
        return 'Autre';
    }
  }

  CommercantModel copyWith({
    String? id,
    String? nom,
    String? description,
    LocalisationModel? localisation,
    List<HoraireModel>? horaires,
    String? imageUrl,
    String? telephone,
    String? email,
    StatutDisponibilite? statutDisponibilite,
    bool? estActif,
    TypeCommercant? typeCommercant,
    List<ProduitModel>? produits,
    List<String>? services,
    double? note,
    int? nombreEvaluations,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return CommercantModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      localisation: localisation ?? this.localisation,
      horaires: horaires ?? this.horaires,
      imageUrl: imageUrl ?? this.imageUrl,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      statutDisponibilite: statutDisponibilite ?? this.statutDisponibilite,
      estActif: estActif ?? this.estActif,
      typeCommercant: typeCommercant ?? this.typeCommercant,
      produits: produits ?? this.produits,
      services: services ?? this.services,
      note: note ?? this.note,
      nombreEvaluations: nombreEvaluations ?? this.nombreEvaluations,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}
