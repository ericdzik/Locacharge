// lib/core/models/eta_result_model.dart
class EtaResult {
  final double durationSeconds; // Durée en secondes
  final double distanceMeters;  // Distance en mètres

  EtaResult({required this.durationSeconds, required this.distanceMeters});

  String get durationFormatted {
    // Formate la durée en minutes ou heures
    if (durationSeconds < 60) {
      return "${durationSeconds.round()} sec";
    }
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) {
      return "$minutes min";
    }
    final hours = (minutes / 60).floor();
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return "$hours h";
    }
    return "$hours h $remainingMinutes min";
  }

  String get distanceFormatted {
    // Formate la distance en mètres ou kilomètres
    if (distanceMeters < 1000) {
      return "${distanceMeters.round()} m";
    }
    final kilometers = (distanceMeters / 1000).toStringAsFixed(1);
    return "$kilometers km";
  }
}
