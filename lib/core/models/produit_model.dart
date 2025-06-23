// lib/core/models/produit_model.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout de l'import

enum TypeProduit {
  rechargeTelephonique,
  forfaitInternet,
  mobileMoney,
  cartesPrepayees,
  servicesNumeriques,
  autres
}

enum StatutProduit { disponible, epuise, temporairementIndisponible }

class ProduitModel {
  final String id;
  final String nom;
  final String description;
  final TypeProduit type;
  final double prix;
  final String devise;
  final StatutProduit statut;
  final String? imageUrl;
  final List<String> operateurs; // MTN, Orange, Moov, etc.
  final Map<String, dynamic>? specifications; // Détails spécifiques au produit
  final DateTime dateCreation;
  final DateTime dateModification;

  ProduitModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.type,
    required this.prix,
    this.devise = 'XOF',
    required this.statut,
    this.imageUrl,
    this.operateurs = const [],
    this.specifications,
    required this.dateCreation,
    required this.dateModification,
  });

  factory ProduitModel.fromJson(Map<String, dynamic> json) {
    return ProduitModel(
      id: json['id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      type: TypeProduit.values.firstWhere(
        (e) => e.toString() == 'TypeProduit.${json['type']}',
        orElse: () => TypeProduit.autres,
      ),
      prix: (json['prix'] as num).toDouble(),
      devise: json['devise'] as String? ?? 'XOF',
      statut: StatutProduit.values.firstWhere(
        (e) => e.toString() == 'StatutProduit.${json['statut']}',
        orElse: () => StatutProduit.disponible,
      ),
      imageUrl: json['imageUrl'] as String?,
      operateurs: List<String>.from(json['operateurs'] ?? []),
      specifications: json['specifications'] as Map<String, dynamic>?,
      dateCreation: (json['dateCreation'] as Timestamp).toDate(),
      dateModification: (json['dateModification'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'type': type.toString().split('.').last,
      'prix': prix,
      'devise': devise,
      'statut': statut.toString().split('.').last,
      'imageUrl': imageUrl,
      'operateurs': operateurs,
      'specifications': specifications,
      'dateCreation': dateCreation.toIso8601String(),
      'dateModification': dateModification.toIso8601String(),
    };
  }

  ProduitModel copyWith({
    String? id,
    String? nom,
    String? description,
    TypeProduit? type,
    double? prix,
    String? devise,
    StatutProduit? statut,
    String? imageUrl,
    List<String>? operateurs,
    Map<String, dynamic>? specifications,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) {
    return ProduitModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      description: description ?? this.description,
      type: type ?? this.type,
      prix: prix ?? this.prix,
      devise: devise ?? this.devise,
      statut: statut ?? this.statut,
      imageUrl: imageUrl ?? this.imageUrl,
      operateurs: operateurs ?? this.operateurs,
      specifications: specifications ?? this.specifications,
      dateCreation: dateCreation ?? this.dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case TypeProduit.rechargeTelephonique:
        return 'Recharge Téléphonique';
      case TypeProduit.forfaitInternet:
        return 'Forfait Internet';
      case TypeProduit.mobileMoney:
        return 'Mobile Money';
      case TypeProduit.cartesPrepayees:
        return 'Cartes Prépayées';
      case TypeProduit.servicesNumeriques:
        return 'Services Numériques';
      case TypeProduit.autres:
        return 'Autres';
    }
  }

  String get statutDisplayName {
    switch (statut) {
      case StatutProduit.disponible:
        return 'Disponible';
      case StatutProduit.epuise:
        return 'Épuisé';
      case StatutProduit.temporairementIndisponible:
        return 'Temporairement indisponible';
    }
  }

  bool get estDisponible => statut == StatutProduit.disponible;
}
