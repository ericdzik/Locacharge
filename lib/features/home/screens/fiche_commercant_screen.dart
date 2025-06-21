// lib/features/home/screens/fiche_commercant_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/services/maps_service.dart'; // Importer le service MapsService
import 'package:locacharge/core/models/eta_result_model.dart'; // Importer EtaResult
import 'package:latlong2/latlong.dart' as latlong; // Pour LatLng avec flutter_map
import 'package:geolocator/geolocator.dart'; // Pour la position utilisateur

class CommercantDetailScreen extends StatefulWidget {
  final CommercantModel commercant;

  const CommercantDetailScreen({super.key, required this.commercant});

  @override
  State<CommercantDetailScreen> createState() => _CommercantDetailScreenState();
}

class _CommercantDetailScreenState extends State<CommercantDetailScreen> {
  final MapsService _mapsService = MapsService(); // Instancier le service
  Future<String>? _etaFutureVoiture;
  Future<String>? _etaFuturePied;

  @override
  void initState() {
    super.initState();
    _loadEtaData();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      }
    } catch (e) {
      print("Erreur Geolocator dans CommercantDetailScreen: $e");
    }
    return null; // Retourne null si permission non accordée ou erreur
  }

  void _loadEtaData() {
    // Pas besoin de setState ici car _etaFutureVoiture et _etaFuturePied sont des Futures
    // et le FutureBuilder réagira à leur changement d'état.
    // On assigne directement les futures.
    _etaFutureVoiture = _getEtaDescriptionWithProfile('car'); // Profil OSRM pour voiture
    _etaFuturePied = _getEtaDescriptionWithProfile('foot');   // Profil OSRM pour piéton
  }

  Future<String> _getEtaDescriptionWithProfile(String osrmProfile) async {
    final Position? userPosition = await _getCurrentPosition();

    if (userPosition == null) {
      return "Position utilisateur inconnue";
    }

    final latlong.LatLng origin = latlong.LatLng(userPosition.latitude, userPosition.longitude);
    final latlong.LatLng destination = latlong.LatLng(widget.commercant.localisation.latitude, widget.commercant.localisation.longitude);

    try {
      // Utiliser la nouvelle méthode du service pour OSRM
      final EtaResult? etaResult = await _mapsService.getEtaFromOSRM(origin, destination, osrmProfile);
      if (etaResult != null) {
        String profileText = "";
        if (osrmProfile == "car") { // Correspond au profil OSRM 'car'
          profileText = "en voiture";
        } else if (osrmProfile == "foot") { // Correspond au profil OSRM 'foot'
          profileText = "à pied";
        }
        return "Environ ${etaResult.durationFormatted} (${etaResult.distanceFormatted}) $profileText";
      } else {
        return "ETA non disponible ($osrmProfile)";
      }
    } catch (e) {
      print("Erreur calcul ETA ($osrmProfile): $e");
      return "Erreur calcul ETA ($osrmProfile)";
    }
  }

  // Helper pour formater les horaires (identique à la version précédente)
  Widget _buildHoraires(BuildContext context) {
    if (widget.commercant.horaires.isEmpty) {
      return const Text("Horaires non disponibles.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.commercant.horaires.map((h) {
        final text = h.estOuvert24h ? "${h.jour}: Ouvert 24h/24" : "${h.jour}: ${h.ouverture} - ${h.fermeture}";
        return Text(text);
      }).toList(),
    );
  }

  Widget _buildEtaDisplay(String title, Future<String> etaFuture) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        FutureBuilder<String>(
          future: etaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text("Calcul en cours...")
                ]
              );
            }
            if (snapshot.hasError) {
              return Text("Erreur ETA: ${snapshot.error}", style: const TextStyle(color: Colors.red));
            }
            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                return const Text("Non disponible");
            }
            return Text(snapshot.data!);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statutColor = widget.commercant.statutDisponibilite == StatutDisponibilite.disponible ? Colors.green :
                        widget.commercant.statutDisponibilite == StatutDisponibilite.epuise ? Colors.red : Colors.grey;
    String statutText = widget.commercant.statutDisponibilite == StatutDisponibilite.disponible ? 'Disponible' :
                        widget.commercant.statutDisponibilite == StatutDisponibilite.epuise ? 'Épuisé' : 'Inconnu';

    String ouvertActuellementText = widget.commercant.estOuvertMaintenant ? "Ouvert actuellement" : "Fermé actuellement";
    Color ouvertColor = widget.commercant.estOuvertMaintenant ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commercant.nom),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.commercant.imageUrl != null && widget.commercant.imageUrl!.isNotEmpty)
              Center(
                child: Hero(
                  tag: 'commercantImage_${widget.commercant.id}',
                  child: Image.network(
                    widget.commercant.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.store_mall_directory, size: 150, color: Colors.grey),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              widget.commercant.nom,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Expanded(child: Text(widget.commercant.localisation.adresse ?? 'Adresse non disponible')),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.phone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(widget.commercant.telephone ?? 'Numéro non disponible'),
              ],
            ),
            const SizedBox(height: 16.0),
            Text("Horaires d'ouverture:", style: Theme.of(context).textTheme.titleMedium),
            _buildHoraires(context),
            const SizedBox(height: 8.0),
            Row(
              children: [
                 Icon(Icons.access_time, color: ouvertColor, size: 20),
                 const SizedBox(width: 8),
                 Text(ouvertActuellementText, style: TextStyle(color: ouvertColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16.0),
            Text("Disponibilité du stock:", style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Icon(Icons.circle, color: statutColor, size: 16),
                const SizedBox(width: 8),
                Text(statutText, style: TextStyle(color: statutColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16.0),
            _buildEtaDisplay("Temps de trajet (voiture):", _etaFutureVoiture!),
            _buildEtaDisplay("Temps de trajet (marche):", _etaFuturePied!),
          ],
        ),
      ),
    );
  }
}
