// lib/core/services/maps_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:locacharge/core/models/eta_result_model.dart'; // Importer le nouveau modèle

class MapsService {
  // Service temporairement désactivé - à remplacer par une API de calcul d'itinéraire gratuite
  // comme OpenRouteService ou OSRM

  Future<EtaResult?> getEtaFromOpenRouteService(
      LatLng origin, LatLng destination, String profile) async {
    // Utilisation d'OpenRouteService (gratuit avec limite)
    // Vous pouvez obtenir une clé gratuite sur https://openrouteservice.org/

    // Pour l'instant, retournons une estimation basique
    return _calculateBasicEta(origin, destination);
  }

  EtaResult _calculateBasicEta(LatLng origin, LatLng destination) {
    // Calcul basique de distance (formule de Haversine)
    const double earthRadius = 6371000; // en mètres

    final double lat1 = origin.latitude * (pi / 180);
    final double lat2 = destination.latitude * (pi / 180);
    final double deltaLat =
        (destination.latitude - origin.latitude) * (pi / 180);
    final double deltaLon =
        (destination.longitude - origin.longitude) * (pi / 180);

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c; // en mètres

    // Estimation basique du temps (vitesse moyenne de 30 km/h en ville)
    final double estimatedDuration =
        distance / (30 * 1000 / 3600); // en secondes

    return EtaResult(
        durationSeconds: estimatedDuration, distanceMeters: distance);
  }

  // Méthode pour obtenir une estimation plus précise avec une API gratuite
  Future<EtaResult?> getEtaFromOSRM(
      LatLng origin, LatLng destination, String profile) async {
    // OSRM est un service de routage open source gratuit
    final String coordinates =
        "${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}";
    final String url =
        "http://router.project-osrm.org/route/v1/$profile/$coordinates?overview=false";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' &&
            data['routes'] != null &&
            data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final double duration = route['duration']?.toDouble() ?? 0.0;
          final double distance = route['distance']?.toDouble() ?? 0.0;

          return EtaResult(durationSeconds: duration, distanceMeters: distance);
        }
      }
    } catch (e) {
      print("Erreur lors de l'appel à OSRM: $e");
    }

    // Fallback vers le calcul basique
    return _calculateBasicEta(origin, destination);
  }
}
