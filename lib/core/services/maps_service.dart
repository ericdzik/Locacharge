// lib/core/services/maps_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:locacharge/core/config/app_config.dart';
import 'package:mapbox_gl/mapbox_gl.dart'; // Pour LatLng
import 'package:locacharge/core/models/eta_result_model.dart'; // Importer le nouveau modèle

class MapsService {
  final String _mapboxAccessToken = AppConfig.mapboxAccessToken;
  // Conserver l'ancienne clé Google API si elle est toujours utilisée ailleurs ou pour une comparaison future
  // final String _googleApiKey = AppConfig.googleDistanceMatrixApiKey;


  Future<EtaResult?> getEtaFromMapbox(LatLng origin, LatLng destination, String profile) async {
    if (_mapboxAccessToken == 'YOUR_MAPBOX_ACCESS_TOKEN' || _mapboxAccessToken.isEmpty) {
      print("Erreur: Clé d'accès Mapbox non configurée.");
      // throw Exception("Clé d'accès Mapbox non configurée."); // Ou retourner null
      return null;
    }

    // Profils Mapbox: mapbox/driving-traffic, mapbox/driving, mapbox/walking, mapbox/cycling
    final String coordinates =
        "${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}";

    final String url =
        "https://api.mapbox.com/directions/v5/$profile/$coordinates?access_token=$_mapboxAccessToken&overview=false&geometries=geojson";
        // overview=false car on n'a besoin que de la durée/distance
        // geometries=geojson est souvent requis même si non utilisé directement

    print("Mapbox Directions API URL: $url"); // Pour débogage

    try {
      final response = await http.get(Uri.parse(url));

      print("Mapbox Directions API Status Code: ${response.statusCode}"); // Pour débogage
      // print("Mapbox Directions API Response Body: ${response.body}"); // Pour débogage détaillé

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0]; // Prendre la première route
          final double duration = route['duration']?.toDouble() ?? 0.0; // en secondes
          final double distance = route['distance']?.toDouble() ?? 0.0; // en mètres

          print("Mapbox ETA: Duration ${duration}s, Distance ${distance}m");
          return EtaResult(durationSeconds: duration, distanceMeters: distance);
        } else {
          print("Erreur de l'API Mapbox Directions: ${data['code']} - ${data['message'] ?? 'Aucune route trouvée ou erreur inconnue'}");
          // throw Exception("Erreur de l'API Mapbox: ${data['code']} - ${data['message'] ?? 'Aucune route trouvée'}");
          return null;
        }
      } else {
        print("Erreur HTTP lors de l'appel à Mapbox Directions: ${response.statusCode} - ${response.body}");
        // throw Exception("Erreur HTTP ${response.statusCode} lors de l'appel à Mapbox Directions");
        return null;
      }
    } catch (e) {
      print("Exception lors de l'appel à Mapbox Directions: $e");
      // throw Exception("Exception lors de l'appel à Mapbox Directions: $e");
      return null;
    }
  }

  // Ancienne méthode Google ETA, peut être conservée pour référence ou supprimée si non utilisée.
  // Future<String> getEtaFromGoogle(LatLng origin, LatLng destination) async {
  //   if (_googleApiKey == 'YOUR_GOOGLE_API_KEY' || _googleApiKey.isEmpty) {
  //     return "Clé API Google non configurée";
  //   }
  //   final String url =
  //       "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$_googleApiKey&units=metric&mode=driving&language=fr";
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == 'OK' && data['rows'][0]['elements'][0]['status'] == 'OK') {
  //         final durationText = data['rows'][0]['elements'][0]['duration']['text'];
  //         return "Environ $durationText en voiture";
  //       } else {
  //         print("Error from Google API: ${data['status']} / ${data['rows'][0]['elements'][0]['status']}");
  //         print("Error message: ${data['error_message']}");
  //         return "ETA non disponible (API Error: ${data['error_message'] ?? data['status']})";
  //       }
  //     } else {
  //       print("Error fetching ETA: ${response.statusCode} ${response.body}");
  //       return "ETA non disponible (HTTP Error ${response.statusCode})";
  //     }
  //   } catch (e) {
  //     print("Exception fetching ETA: $e");
  //     return "ETA non disponible (Exception)";
  //   }
  // }
}
