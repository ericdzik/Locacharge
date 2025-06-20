// lib/core/models/commercant_model.dart
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';

enum StatutDisponibilite {
  disponible,
  epuise,
  inconnu,
}

class CommercantModel {
  final String id;
  final String nom;
  final LocalisationModel localisation;
  final List<HoraireModel> horaires;
  final String? imageUrl;
  final String? telephone;
  final StatutDisponibilite statutDisponibilite; // Pour le stock
  final bool estActif; // Pour l'administrateur (point actif/désactivé)

  // Potentiellement d'autres champs comme description, services offerts etc.

  CommercantModel({
    required this.id,
    required this.nom,
    required this.localisation,
    required this.horaires,
    this.imageUrl,
    this.telephone,
    this.statutDisponibilite = StatutDisponibilite.inconnu,
    this.estActif = true,
  });

  // Méthode pour la sérialisation/désérialisation Firestore
  factory CommercantModel.fromMap(String id, Map<String, dynamic> data) {
    return CommercantModel(
      id: id,
      nom: data['nom'] as String,
      localisation: LocalisationModel.fromMap(data['localisation'] as Map<String, dynamic>),
      horaires: (data['horaires'] as List<dynamic>? ?? [])
          .map((h) => HoraireModel.fromMap(h as Map<String, dynamic>))
          .toList(),
      imageUrl: data['imageUrl'] as String?,
      telephone: data['telephone'] as String?,
      statutDisponibilite: StatutDisponibilite.values.firstWhere(
        (e) => e.toString() == data['statutDisponibilite'],
        orElse: () => StatutDisponibilite.inconnu,
      ),
      estActif: data['estActif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'localisation': localisation.toMap(),
      'horaires': horaires.map((h) => h.toMap()).toList(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (telephone != null) 'telephone': telephone,
      'statutDisponibilite': statutDisponibilite.toString(),
      'estActif': estActif,
    };
  }

  // Helper pour déterminer si le commerçant est ouvert (basé sur ses horaires)
  bool get estOuvertMaintenant {
    return estActuellementOuvert(horaires); // Utilise la fonction de horaire_model
  }
}
