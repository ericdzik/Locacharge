// lib/core/services/maps_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:locacharge/core/config/app_config.dart'; // Pour la clé API Google
import 'package:mapbox_gl/mapbox_gl.dart'; // Pour LatLng

class MapsService {
  final String _googleApiKey = AppConfig.googleDistanceMatrixApiKey;

  Future<String> getEtaFromGoogle(LatLng origin, LatLng destination) async {
    if (_googleApiKey == 'YOUR_GOOGLE_API_KEY' || _googleApiKey.isEmpty) {
      return "Clé API Google non configurée";
    }

    final String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin.latitude},${origin.longitude}&destinations=${destination.latitude},${destination.longitude}&key=$_googleApiKey&units=metric&mode=driving&language=fr";
        // On peut ajouter &mode=walking pour la marche, ou faire deux appels.

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['rows'][0]['elements'][0]['status'] == 'OK') {
          final durationText = data['rows'][0]['elements'][0]['duration']['text'];
          // final distanceText = data['rows'][0]['elements'][0]['distance']['text'];
          return "Environ $durationText en voiture"; // Exemple
        } else {
          print("Error from Google API: ${data['status']} / ${data['rows'][0]['elements'][0]['status']}");
          print("Error message: ${data['error_message']}");
          return "ETA non disponible (API Error: ${data['error_message'] ?? data['status']})";
        }
      } else {
        print("Error fetching ETA: ${response.statusCode} ${response.body}");
        return "ETA non disponible (HTTP Error ${response.statusCode})";
      }
    } catch (e) {
      print("Exception fetching ETA: $e");
      return "ETA non disponible (Exception)";
    }
  }
}
