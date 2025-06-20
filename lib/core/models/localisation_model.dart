// lib/core/models/localisation_model.dart
class LocalisationModel {
  final double latitude;
  final double longitude;
  final String? adresse; // Adresse textuelle optionnelle

  LocalisationModel({
    required this.latitude,
    required this.longitude,
    this.adresse,
  });

  // Méthode pour la sérialisation/désérialisation Firestore
  factory LocalisationModel.fromMap(Map<String, dynamic> data) {
    return LocalisationModel(
      latitude: data['latitude'] as double,
      longitude: data['longitude'] as double,
      adresse: data['adresse'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (adresse != null) 'adresse': adresse,
    };
  }
}
