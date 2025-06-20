// lib/features/home/widgets/commercant_list_item.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
// Importer CommercantDetailScreen pour la navigation
import 'package:locacharge/features/home/screens/fiche_commercant_screen.dart'; // Temporairement fiche_commercant_screen

class CommercantListItem extends StatelessWidget {
  final CommercantModel commercant;

  const CommercantListItem({super.key, required this.commercant});

  @override
  Widget build(BuildContext context) {
    Color statutColor = Colors.grey;
    IconData statutIcon = Icons.help_outline;

    if (commercant.statutDisponibilite == StatutDisponibilite.disponible) {
      statutColor = Colors.green;
      statutIcon = Icons.check_circle_outline;
    } else if (commercant.statutDisponibilite == StatutDisponibilite.epuise) {
      statutColor = Colors.red;
      statutIcon = Icons.highlight_off_outlined;
    }

    // Simplification des horaires pour l'affichage liste
    String horaireSimplifie = "Horaires non disponibles";
    if (commercant.horaires.isNotEmpty) {
      final premierHoraire = commercant.horaires.first;
      if (premierHoraire.estOuvert24h) {
        horaireSimplifie = "Ouvert 24h/24";
      } else {
        horaireSimplifie = "${premierHoraire.ouverture} - ${premierHoraire.fermeture}";
      }
    }
    if (!commercant.estOuvertMaintenant) {
        horaireSimplifie = "Fermé actuellement";
    }


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statutColor,
          child: commercant.imageUrl != null && commercant.imageUrl!.isNotEmpty
              ? ClipOval(child: Image.network(commercant.imageUrl!, fit: BoxFit.cover, width: 50, height: 50, errorBuilder: (c, o, s) => Icon(statutIcon, color: Colors.white)))
              : Icon(statutIcon, color: Colors.white),
        ),
        title: Text(commercant.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(commercant.localisation.adresse ?? 'Adresse non spécifiée'),
            Text("Tél: ${commercant.telephone ?? 'N/A'}"),
            Text("Horaire: $horaireSimplifie"),
            Row(
              children: [
                Icon(Icons.circle, color: statutColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  commercant.statutDisponibilite == StatutDisponibilite.disponible ? 'Disponible' :
                  commercant.statutDisponibilite == StatutDisponibilite.epuise ? 'Épuisé' : 'Inconnu',
                  style: TextStyle(color: statutColor),
                ),
              ],
            )
          ],
        ),
        isThreeLine: true, // Permet plus d'espace pour le sous-titre
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // Utiliser fiche_commercant_screen.dart comme CommercantDetailScreen
              builder: (context) => CommercantDetailScreen(commercant: commercant),
            ),
          );
        },
      ),
    );
  }
}
