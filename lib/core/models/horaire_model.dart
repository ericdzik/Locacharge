// lib/core/models/horaire_model.dart
class HoraireModel {
  final String jour; // Ex: "Lundi", "Mardi", etc. ou un index de jour
  final String ouverture; // Ex: "09:00"
  final String fermeture; // Ex: "18:00"
  final bool estOuvert24h; // Si le lieu est ouvert 24h ce jour-là

  HoraireModel({
    required this.jour,
    required this.ouverture,
    required this.fermeture,
    this.estOuvert24h = false,
  });

  // Méthode pour la sérialisation/désérialisation Firestore
  factory HoraireModel.fromMap(Map<String, dynamic> data) {
    return HoraireModel(
      jour: data['jour'] as String,
      ouverture: data['ouverture'] as String,
      fermeture: data['fermeture'] as String,
      estOuvert24h: data['estOuvert24h'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jour': jour,
      'ouverture': ouverture,
      'fermeture': fermeture,
      'estOuvert24h': estOuvert24h,
    };
  }
}

// Helper pour déterminer si c'est ouvert basé sur une liste d'horaires
bool estActuellementOuvert(List<HoraireModel> horaires) {
  if (horaires.isEmpty) return true; // Par défaut ouvert s'il n'y a pas d'horaires spécifiés (à discuter)

  // Ceci est une logique SIMPLIFIÉE. Une vraie implémentation nécessiterait:
  // - Connaître le jour actuel de la semaine.
  // - Parser les chaînes "ouverture" et "fermeture" en objets TimeOfDay ou DateTime.
  // - Gérer les cas où un commerce est ouvert au-delà de minuit.
  // - Utiliser 'intl' pour un parsing robuste des jours et heures selon la locale.

  final now = DateTime.now();
  // Pour l'exemple, on ne vérifie que le premier horaire et on suppose qu'il s'applique à aujourd'hui
  // Et on ne compare que très grossièrement les heures.
  final todayHoraire = horaires.firstWhere((h) {
    // Ici il faudrait mapper h.jour (ex: "Lundi") au jour actuel de la semaine
    // Pour l'instant, on prend le premier horaire disponible pour la démo.
    return true;
  }, orElse: () => HoraireModel(jour: "default", ouverture: "00:00", fermeture: "00:00")); // Ne devrait pas arriver si horaires non vide

  if (todayHoraire.estOuvert24h) return true;

  try {
    final openHour = int.tryParse(todayHoraire.ouverture.split(":")[0]);
    final openMinute = int.tryParse(todayHoraire.ouverture.split(":")[1]);
    final closeHour = int.tryParse(todayHoraire.fermeture.split(":")[0]);
    final closeMinute = int.tryParse(todayHoraire.fermeture.split(":")[1]);

    if (openHour == null || openMinute == null || closeHour == null || closeMinute == null) {
      return true; // Incapable de parser, on suppose ouvert
    }

    final openTime = DateTime(now.year, now.month, now.day, openHour, openMinute);
    DateTime closeTime = DateTime(now.year, now.month, now.day, closeHour, closeMinute);

    // Gérer le cas où la fermeture est le lendemain (ex: 22:00 - 02:00)
    if (closeTime.isBefore(openTime)) {
      closeTime = closeTime.add(const Duration(days: 1));
      // Si l'heure actuelle est aussi après minuit et avant l'heure de fermeture, il faut aussi ajuster 'now'
      // ou avoir une logique plus complexe. Pour simplifier, on ne gère pas ce cas finement ici.
    }

    return now.isAfter(openTime) && now.isBefore(closeTime);
  } catch (e) {
    print("Erreur de parsing d'horaire: $e");
    return true; // En cas d'erreur, on suppose ouvert pour ne pas bloquer
  }
}
