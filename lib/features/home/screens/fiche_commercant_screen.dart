// lib/features/home/screens/fiche_commercant_screen.dart
// (Considérez ce fichier comme CommercantDetailScreen pour cette étape)
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/horaire_model.dart'; // Pour la fonction estActuellementOuvert
// import 'package:url_launcher/url_launcher.dart'; // Pour lancer des appels ou des cartes

class CommercantDetailScreen extends StatelessWidget {
  final CommercantModel commercant;

  const CommercantDetailScreen({super.key, required this.commercant});

  // Helper pour formater les horaires
  Widget _buildHoraires(BuildContext context) {
    if (commercant.horaires.isEmpty) {
      return const Text("Horaires non disponibles.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: commercant.horaires.map((h) {
        final text = h.estOuvert24h ? "${h.jour}: Ouvert 24h/24" : "${h.jour}: ${h.ouverture} - ${h.fermeture}";
        return Text(text);
      }).toList(),
    );
  }

  // Placeholder pour la fonction d'appel à l'API Distance Matrix
  Future<String> _getEtaDescription() async {
    // TODO: Implémenter l'appel réel à Google Distance Matrix API
    // Pour l'instant, retourne une valeur factice
    await Future.delayed(const Duration(milliseconds: 500)); // Simule un appel réseau
    // Simuler une logique basée sur la distance brute (très approximatif)
    // Position utilisateur factice pour l'exemple (devrait venir de Geolocator/état global)
    final userLat = 5.3454;
    final userLng = -4.0245;
    final dLat = (commercant.localisation.latitude - userLat).abs();
    final dLng = (commercant.localisation.longitude - userLng).abs();
    final distance = dLat + dLng; // Approximation très grossière

    if (distance < 0.01) return "Environ 5 min à pied";
    if (distance < 0.05) return "Environ 10 min en voiture / 20 min à pied";
    return "Plus de 15 min en voiture";
  }


  @override
  Widget build(BuildContext context) {
    Color statutColor = commercant.statutDisponibilite == StatutDisponibilite.disponible ? Colors.green :
                        commercant.statutDisponibilite == StatutDisponibilite.epuise ? Colors.red : Colors.grey;
    String statutText = commercant.statutDisponibilite == StatutDisponibilite.disponible ? 'Disponible' :
                        commercant.statutDisponibilite == StatutDisponibilite.epuise ? 'Épuisé' : 'Inconnu';

    String ouvertActuellementText = commercant.estOuvertMaintenant ? "Ouvert actuellement" : "Fermé actuellement";
    Color ouvertColor = commercant.estOuvertMaintenant ? Colors.green.shade700 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        title: Text(commercant.nom),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (commercant.imageUrl != null && commercant.imageUrl!.isNotEmpty)
              Center(
                child: Hero( // Animation Hero pour l'image
                  tag: 'commercantImage_${commercant.id}', // Tag unique
                  child: Image.network(
                    commercant.imageUrl!,
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
              commercant.nom,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Expanded(child: Text(commercant.localisation.adresse ?? 'Adresse non disponible')),
                // IconButton(icon: Icon(Icons.map), onPressed: () async {
                //   final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${commercant.localisation.latitude},${commercant.localisation.longitude}";
                //   if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                //     await launchUrl(Uri.parse(googleMapsUrl));
                //   }
                // })
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.phone, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(commercant.telephone ?? 'Numéro non disponible'),
                // IconButton(icon: Icon(Icons.call), onPressed: () async {
                //   if (commercant.telephone != null) {
                //     final Uri launchUri = Uri(scheme: 'tel', path: commercant.telephone);
                //     if (await canLaunchUrl(launchUri)) {
                //        await launchUrl(launchUri);
                //     }
                //   }
                // })
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
            Text("Temps de trajet estimé (ETA):", style: Theme.of(context).textTheme.titleMedium),
            FutureBuilder<String>(
              future: _getEtaDescription(), // Appel de la fonction (actuellement factice)
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Row(children: [CircularProgressIndicator(strokeWidth: 2), SizedBox(width: 8), Text("Calcul en cours...")]);
                }
                if (snapshot.hasError) {
                  return Text("Erreur ETA: ${snapshot.error}");
                }
                return Text(snapshot.data ?? "Non disponible");
              },
            ),
            // TODO: Ajouter une petite carte statique Mapbox si pertinent ici (plus complexe)
          ],
        ),
      ),
    );
  }
}
