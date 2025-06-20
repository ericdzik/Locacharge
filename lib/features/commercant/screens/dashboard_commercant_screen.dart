// lib/features/commercant/screens/dashboard_commercant_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/user_model.dart';
import 'package:locacharge/core/models/role_enum.dart'; // Import UserRole
import 'package:locacharge/core/services/auth_service.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/user_service.dart';
// import 'package:provider/provider.dart'; // Si vous utilisez Provider

class DashboardCommercantScreen extends StatefulWidget {
  const DashboardCommercantScreen({super.key});

  @override
  State<DashboardCommercantScreen> createState() => _DashboardCommercantScreenState();
}

class _DashboardCommercantScreenState extends State<DashboardCommercantScreen> {
  final AuthService _authService = AuthService(); //TODO: Inject with Provider
  final CommercantService _commercantService = CommercantService(); //TODO: Inject with Provider
  final UserService _userService = UserService(); //TODO: Inject with Provider

  UserModel? _currentUserData;
  CommercantModel? _commercantData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _isLoading = true; });
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      // Rediriger vers login si pas d'utilisateur (ne devrait pas arriver si bien protégé)
      // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non connecté. Redirection nécessaire (TODO).")),
        );
        setState(() {_isLoading = false;});
      }
      return;
    }

    _currentUserData = await _userService.getUserById(firebaseUser.uid);
    // Supposons que l'ID utilisateur est l'ID du document commerçant
    if (_currentUserData?.role == UserRole.commercant) {
      _commercantData = await _commercantService.getCommercantByUserId(firebaseUser.uid);
    } else {
       _commercantData = null; // S'assurer qu'il est null si ce n'est pas un commerçant
    }

    if (!mounted) return;
    setState(() { _isLoading = false; });
  }

  Future<void> _updateDisponibilite(StatutDisponibilite newStatut) async {
    if (_commercantData == null) return;
    // Utiliser _commercantData!.id car si _commercantData est non-null, son id l'est aussi (selon le modèle)
    // Cependant, il faut s'assurer que l'ID du commerçant est bien celui utilisé dans Firestore.
    // Si l'ID du document commerçant est l'UID de l'utilisateur, alors _commercantData.id peut être différent
    // si CommercantModel.fromMap assigne un ID interne différent de l'ID du document.
    // Pour cette implémentation, on suppose que _commercantData.id EST l'ID du document.
    final String docIdToUpdate = _commercantData!.id;


    setState(() { _isLoading = true; });
    try {
      await _commercantService.updateDisponibilite(docIdToUpdate, newStatut);
      await _loadData(); // Recharger les données pour refléter le changement
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur maj disponibilité: $e")));
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_commercantData?.nom ?? 'Tableau de Bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              // TODO: Naviguer vers l'écran de connexion après déconnexion
              // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
               if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Déconnexion réussie (Navigation TODO).')),
                  );
                }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUserData == null // Vérifier si _currentUserData est null (cas où l'utilisateur n'est pas dans Firestore users)
              ? Center(child: Text(
                  "Impossible de charger les données utilisateur. Veuillez réessayer ou contacter le support."
                ))
              : _commercantData == null && _currentUserData?.role == UserRole.commercant
                  ? Center(child: Text(
                      "Profil commerçant non trouvé pour ${firebaseUser.email}. Veuillez contacter l'administrateur."
                    ))
                  : _currentUserData?.role != UserRole.commercant
                     ? const Center(child: Text("Accès réservé aux commerçants."))
                     : RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Bienvenue, ${_currentUserData?.nomComplet ?? _currentUserData?.email ?? 'Commerçant'}!", style: Theme.of(context).textTheme.headlineSmall),
                                const SizedBox(height: 20),
                                Text("Statut du point de vente:", style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text("Disponible"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                      onPressed: _commercantData?.statutDisponibilite == StatutDisponibilite.disponible
                                          ? null // Déjà disponible
                                          : () => _updateDisponibilite(StatutDisponibilite.disponible),
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.cancel),
                                      label: const Text("Épuisé"),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                      onPressed: _commercantData?.statutDisponibilite == StatutDisponibilite.epuise
                                          ? null // Déjà épuisé
                                          : () => _updateDisponibilite(StatutDisponibilite.epuise),
                                    ),
                                  ],
                                ),
                                if (_commercantData?.statutDisponibilite != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Center(child: Text("Actuellement: ${_commercantData!.statutDisponibilite.toString().split('.').last}", style: TextStyle(fontWeight: FontWeight.bold, color: _commercantData!.statutDisponibilite == StatutDisponibilite.disponible ? Colors.green : _commercantData!.statutDisponibilite == StatutDisponibilite.epuise ? Colors.red : Colors.grey ))),
                                  ),
                                const Divider(height: 40),
                                Text("Gérer mes informations:", style: Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                ListTile(
                                  leading: const Icon(Icons.schedule),
                                  title: const Text("Modifier les horaires"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Modification des horaires (Prochainement)')),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: const Text("Modifier le numéro de téléphone"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Modification du téléphone (Prochainement)')),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.image),
                                  title: const Text("Modifier l'image de la boutique"),
                                  trailing: const Icon(Icons.arrow_forward_ios),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Modification de l'image (Prochainement)")),
                                    );
                                  },
                                ),
                                // Placeholder pour les stats V2
                                // const Divider(height: 40),
                                // Text("Statistiques (V2):", style: Theme.of(context).textTheme.titleLarge),
                                // const SizedBox(height: 8),
                                // Text("Nombre de vues de la fiche: (Prochainement)"),
                              ],
                            ),
                          ),
                        ),
        );
      }
    }
