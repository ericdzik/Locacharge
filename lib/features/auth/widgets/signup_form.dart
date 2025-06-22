// lib/features/auth/widgets/signup_form.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/role_enum.dart';
import 'package:locacharge/core/models/user_model.dart';
import 'package:locacharge/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/user_service.dart';
// Importer les écrans pour la redirection
import 'package:locacharge/app/main_navigation_shell.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart';
import 'package:locacharge/features/commercant/screens/dashboard_commercant_screen.dart';


class SignUpForm extends StatefulWidget {
  final UserRole role; // Accepter le rôle

  const SignUpForm({super.key, required this.role});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Optionnel: Ajouter un champ pour le nom de la boutique si commerçant
  final _nomBoutiqueController = TextEditingController();

  final _authService = AuthService(); // Instancier les services
  final _userService = UserService();
  final _commercantService = CommercantService();

  bool _isLoading = false;
  String? _error;

  void _signup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nomBoutique = _nomBoutiqueController.text.trim(); // Pour commerçant

    if (email.isEmpty || !email.contains('@')) {
        if (mounted) setState(() => _error = "Veuillez entrer un email valide.");
        return;
    }
    if (password.length < 6) {
      if (mounted) setState(() => _error = "Le mot de passe doit comporter au moins 6 caractères.");
      return;
    }
    if (widget.role == UserRole.commercant && nomBoutique.isEmpty) {
      if (mounted) setState(() => _error = "Le nom de la boutique est requis pour les commerçants.");
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      UserCredential userCredential = await _authService.signUpWithEmail(email, password);
      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Créer UserModel dans Firestore
        final userModel = UserModel(
          id: firebaseUser.uid,
          email: email,
          role: widget.role,
          // nomComplet: Peut être ajouté plus tard ou via un champ de formulaire
        );
        await _userService.createUser(userModel);

        // Si c'est un commerçant, créer aussi l'entrée CommercantModel
        if (widget.role == UserRole.commercant) {
          final commercantModel = CommercantModel(
            id: firebaseUser.uid, // Utiliser l'UID comme ID du commerçant
            nom: nomBoutique.isNotEmpty ? nomBoutique : "Commerçant (Nom à définir)",
            localisation: LocalisationModel(latitude: 0, longitude: 0, adresse: "Adresse à définir"), // Valeurs par défaut
            horaires: [], // Vide par défaut
            statutDisponibilite: StatutDisponibilite.inconnu, // Par défaut
          );
          await _commercantService.createOrUpdateCommercant(commercantModel);
        }

        // Logique de redirection (similaire à LoginRedirectLogic)
        if (mounted) {
            // Relire le userModel depuis Firestore pour être sûr d'avoir le rôle correct pour la redirection
            final freshUserModel = await _userService.getUserById(firebaseUser.uid);
            if (!mounted) return; // Vérifier à nouveau après l'appel asynchrone

            if (freshUserModel == null) {
                setState(() => _error = "Erreur de création du profil utilisateur.");
                return; // Rester sur la page d'inscription avec erreur
            }

            if (freshUserModel.role == UserRole.admin) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AdminDashboardScreen()), (route) => false);
            } else if (freshUserModel.role == UserRole.commercant) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const DashboardCommercantScreen()), (route) => false);
            } else { // Client
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainNavigationShell()), (route) => false);
            }
        }
      } else {
         if (mounted) setState(() => _error = "Erreur lors de la création du compte Firebase.");
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur d'inscription : ${e.message}");
      String errorMessage = "Une erreur est survenue lors de l'inscription.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Cette adresse email est déjà utilisée par un autre compte.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Le mot de passe fourni est trop faible.";
      }
      if (mounted) setState(() => _error = errorMessage);
    } catch (e) {
      // Pour autres erreurs (ex: Firestore indisponible)
      debugPrint("Erreur générale d'inscription : $e");
      if (mounted) setState(() => _error = "Une erreur inattendue est survenue.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomBoutiqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Créer un compte ${widget.role == UserRole.commercant ? 'Commerçant' : 'Client'}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.role == UserRole.commercant) ...[
                  TextField(
                    controller: _nomBoutiqueController,
                    decoration: InputDecoration(
                      labelText: "Nom de la boutique",
                      filled: true,
                      fillColor: Colors.green.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.shade600)),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Adresse email",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.shade600)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Mot de passe (min. 6 caractères)",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green.shade600)),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signup,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Créer mon compte ${widget.role == UserRole.commercant ? 'Commerçant' : 'Client'}",
                            style: const TextStyle(fontSize: 16, color: Colors.white), // Couleur du texte explicite
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Si SignUpScreen a été poussé par dessus LoginScreen ou RoleSelectionScreen
                    Navigator.pop(context);
                  },
                  child: const Text("Déjà un compte ? Se connecter"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
