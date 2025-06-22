// lib/features/commercant/screens/dashboard_commercant_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/user_model.dart';
import 'package:locacharge/core/models/role_enum.dart'; // Import UserRole
import 'package:locacharge/core/services/auth_service.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/user_service.dart';
import 'package:locacharge/core/services/analytics_service.dart';
import 'package:locacharge/features/commercant/screens/edit_commercant_screen.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
// import 'package:provider/provider.dart'; // Si vous utilisez Provider

class DashboardCommercantScreen extends StatefulWidget {
  const DashboardCommercantScreen({super.key});

  @override
  State<DashboardCommercantScreen> createState() =>
      _DashboardCommercantScreenState();
}

class _DashboardCommercantScreenState extends State<DashboardCommercantScreen> {
  final AuthService _authService = AuthService(); //TODO: Inject with Provider
  final CommercantService _commercantService =
      CommercantService(); //TODO: Inject with Provider
  final UserService _userService = UserService(); //TODO: Inject with Provider
  final AnalyticsService _analyticsService =
      AnalyticsService(); //TODO: Inject with Provider

  UserModel? _currentUserData;
  CommercantModel? _commercantData;
  bool _isLoading = true;
  int _visitsCount = 0; // Compteur de visites (simulé)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      // Rediriger vers login si pas d'utilisateur (ne devrait pas arriver si bien protégé)
      // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  "Utilisateur non connecté. Redirection nécessaire (TODO).")),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    _currentUserData = await _userService.getUserById(firebaseUser.uid);
    // Supposons que l'ID utilisateur est l'ID du document commerçant
    if (_currentUserData?.role == UserRole.commercant) {
      _commercantData =
          await _commercantService.getCommercantByUserId(firebaseUser.uid);
      // Charger les vraies statistiques de visites
      if (_commercantData != null) {
        _visitsCount = await _analyticsService
            .getCommercantViews(_commercantData!.id, days: 30);
      }
    } else {
      _commercantData =
          null; // S'assurer qu'il est null si ce n'est pas un commerçant
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateDisponibilite(StatutDisponibilite newStatut) async {
    if (_commercantData == null) return;
    // Utiliser _commercantData!.id car si _commercantData est non-null, son id l'est aussi (selon le modèle)
    // Cependant, il faut s'assurer que l'ID du commerçant est bien celui utilisé dans Firestore.
    // Si l'ID du document commerçant est l'UID de l'utilisateur, alors _commercantData.id peut être différent
    // si CommercantModel.fromMap assigne un ID interne différent de l'ID du document.
    // Pour cette implémentation, on suppose que _commercantData.id EST l'ID du document.
    final String docIdToUpdate = _commercantData!.id;

    setState(() {
      _isLoading = true;
    });
    try {
      await _commercantService.updateDisponibilite(docIdToUpdate, newStatut);
      await _loadData(); // Recharger les données pour refléter le changement
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur maj disponibilité: $e")));
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
  }

  Future<void> _editCommercantInfo() async {
    if (_commercantData == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditCommercantScreen(commercant: _commercantData!),
      ),
    );

    if (result == true) {
      // Recharger les données si des modifications ont été apportées
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(_commercantData?.nom ?? 'Tableau de Bord'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textPrimary),
            onPressed: () async {
              await _authService.signOut();
              // TODO: Naviguer vers l'écran de connexion après déconnexion
              // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Déconnexion réussie (Navigation TODO).')),
                );
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : _currentUserData ==
                  null // Vérifier si _currentUserData est null (cas où l'utilisateur n'est pas dans Firestore users)
              ? Center(
                  child: Text(
                  "Impossible de charger les données utilisateur. Veuillez réessayer ou contacter le support.",
                  style: TextStyle(color: AppColors.textPrimary),
                ))
              : _commercantData == null &&
                      _currentUserData?.role == UserRole.commercant
                  ? Center(
                      child: Text(
                      "Profil commerçant non trouvé pour l'utilisateur (${_currentUserData?.email ?? _currentUserData?.id ?? 'ID inconnu'}). Veuillez contacter l'administrateur.",
                      style: TextStyle(color: AppColors.textPrimary),
                    ))
                  : _currentUserData?.role != UserRole.commercant
                      ? Center(
                          child: Text(
                          "Accès réservé aux commerçants.",
                          style: TextStyle(color: AppColors.textPrimary),
                        ))
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête avec informations du commerçant
                                ModernCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Bienvenue, ${_currentUserData?.nomComplet ?? _currentUserData?.email ?? 'Commerçant'}!",
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _commercantData?.description ??
                                            'Point de vente de services numériques',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Statut du point de vente
                                ModernCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Statut du point de vente",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ModernPrimaryButton(
                                              text: "Disponible",
                                              onPressed: _commercantData
                                                          ?.statutDisponibilite ==
                                                      StatutDisponibilite
                                                          .disponible
                                                  ? null // Déjà disponible
                                                  : () => _updateDisponibilite(
                                                      StatutDisponibilite
                                                          .disponible),
                                              icon: Icons.check_circle,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ModernSecondaryButton(
                                              text: "Épuisé",
                                              onPressed: _commercantData
                                                          ?.statutDisponibilite ==
                                                      StatutDisponibilite.epuise
                                                  ? null // Déjà épuisé
                                                  : () => _updateDisponibilite(
                                                      StatutDisponibilite
                                                          .epuise),
                                              icon: Icons.cancel,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_commercantData
                                              ?.statutDisponibilite !=
                                          null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 12.0),
                                          child: Center(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _commercantData!
                                                            .statutDisponibilite ==
                                                        StatutDisponibilite
                                                            .disponible
                                                    ? AppColors.successColor
                                                        .withOpacity(0.1)
                                                    : AppColors.errorColor
                                                        .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Actuellement: ${_commercantData!.statutDisponibilite.toString().split('.').last}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _commercantData!
                                                              .statutDisponibilite ==
                                                          StatutDisponibilite
                                                              .disponible
                                                      ? AppColors.successColor
                                                      : AppColors.errorColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Statistiques
                                ModernCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Statistiques",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.visibility,
                                              title: "Vues de la fiche",
                                              value: _visitsCount.toString(),
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildStatCard(
                                              icon: Icons.star,
                                              title: "Note moyenne",
                                              value: _commercantData?.note
                                                      ?.toStringAsFixed(1) ??
                                                  "N/A",
                                              color: AppColors.accentColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Gestion des informations
                                ModernCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Gérer mes informations",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ListTile(
                                        leading: const Icon(Icons.edit,
                                            color: AppColors.primaryColor),
                                        title: const Text(
                                          "Modifier mes informations",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: const Text(
                                          "Nom, description, contact, image",
                                          style: TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.textLight),
                                        onTap: _editCommercantInfo,
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.schedule,
                                            color: AppColors.primaryColor),
                                        title: const Text(
                                          "Horaires d'ouverture",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${_commercantData?.horaires.length ?? 0} plage(s) configurée(s)",
                                          style: const TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.textLight),
                                        onTap: _editCommercantInfo,
                                      ),
                                      const Divider(),
                                      ListTile(
                                        leading: const Icon(Icons.inventory,
                                            color: AppColors.primaryColor),
                                        title: const Text(
                                          "Gérer les produits",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "${_commercantData?.produits.length ?? 0} produit(s) configuré(s)",
                                          style: const TextStyle(
                                              color: AppColors.textSecondary),
                                        ),
                                        trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: AppColors.textLight),
                                        onTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    'Gestion des produits (Prochainement)')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
