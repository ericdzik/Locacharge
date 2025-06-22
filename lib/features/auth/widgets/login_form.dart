import 'package:flutter/material.dart';
import 'package:locacharge/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locacharge/core/services/user_service.dart';
import 'package:locacharge/features/auth/screens/login_redirect_logic.dart';
import 'package:locacharge/features/auth/screens/role_selection_screen.dart'; // Ajouter RoleSelectionScreen

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService(); // Instancier UserService
  bool _isLoading = false;
  String? _error;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = "Email et mot de passe requis");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AuthService().signInWithEmail(email, password);
      final firebaseUser = AuthService().currentUser; // Récupérer l'utilisateur Firebase
      if (mounted && firebaseUser != null) {
        // Appeler la logique de redirection
        await LoginRedirectLogic.handleLoginSuccess(context, firebaseUser, _userService);
      } else if (mounted) {
        // Cas où firebaseUser est null après une tentative de connexion réussie (improbable)
        setState(() => _error = "Erreur de récupération de l'utilisateur après connexion.");
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
                const Text(
                  "Connexion",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Adresse email",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    filled: true,
                    fillColor: Colors.green.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade600),
                    ),
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
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.login, size: 20),
    label: const Text(
      "Continuer avec Google",
      overflow: TextOverflow.ellipsis,
    ),
    onPressed: () async {
      setState(() => _isLoading = true);
      try {
        final userCredential = await AuthService().signInWithGoogle();
        final firebaseUser = userCredential?.user; // Récupérer l'utilisateur Firebase
        if (mounted && firebaseUser != null) {
          // Appeler la logique de redirection
          await LoginRedirectLogic.handleLoginSuccess(context, firebaseUser, _userService);
        } else if (mounted) {
          // Cas où firebaseUser est null (connexion Google annulée ou échouée)
           if (userCredential == null) { // Si userCredential lui-même est null (connexion annulée par exemple)
             // Pas besoin de message d'erreur spécifique, l'utilisateur a annulé
           } else {
            setState(() => _error = "Échec de la connexion Google ou utilisateur non trouvé.");
           }
        }
      } catch (e) {
        if (mounted) setState(() => _error = "Échec de la connexion Google: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
),



                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    );
                  },
                  child: const Text("Pas encore de compte ? S'inscrire"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
