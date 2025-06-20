// lib/features/admin/screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/auth_service.dart'; // Pour déconnexion
import 'package:locacharge/features/admin/screens/add_edit_commercant_screen.dart';
// import 'package:provider/provider.dart'; // Si utilisé

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final CommercantService _commercantService = CommercantService(); // TODO: Inject
  final AuthService _authService = AuthService(); // TODO: Inject

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // TODO: Naviguer vers l'écran de connexion
              // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Déconnexion (Nav TODO)")));
            },
          ),
        ],
      ),
      body: StreamBuilder<List<CommercantModel>>(
        stream: _commercantService.getAllCommercantsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun commerçant trouvé."));
          }

          List<CommercantModel> commercants = snapshot.data!;

          return ListView.builder(
            itemCount: commercants.length,
            itemBuilder: (context, index) {
              final commercant = commercants[index];
              return ListTile(
                title: Text(commercant.nom),
                subtitle: Text("ID: ${commercant.id} - Statut: ${commercant.statutDisponibilite.toString().split('.').last}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditCommercantScreen(commercantToEdit: commercant),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('Confirmer Suppression'),
                            content: Text('Voulez-vous vraiment supprimer ${commercant.nom}?'),
                            actions: <Widget>[
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Annuler')),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Supprimer')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          try {
                            await _commercantService.deleteCommercant(commercant.id);
                            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${commercant.nom} supprimé.')));
                          } catch (e) {
                            if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur suppression: $e')));
                          }
                        }
                      },
                    ),
                  ],
                ),
                // TODO: Afficher plus d'infos si nécessaire (actif/inactif)
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditCommercantScreen()),
          );
        },
        child: const Icon(Icons.add_business),
        tooltip: 'Ajouter Commerçant',
      ),
    );
  }
}
