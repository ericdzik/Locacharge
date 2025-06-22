// lib/features/auth/screens/role_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/role_enum.dart';
import 'package:locacharge/features/auth/screens/signup_screen.dart'; // Pour naviguer vers l'inscription

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigateToSignUp(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rejoindre LocaCharge"), // TODO: Internationaliser
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Comment souhaitez-vous utiliser LocaCharge ?", // TODO: Internationaliser
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_outline),
                label: const Text("Je suis un Client"), // TODO: Internationaliser
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  // backgroundColor: Theme.of(context).colorScheme.primary, // Utilisez vos couleurs de thème
                  // foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _navigateToSignUp(context, UserRole.client);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.store_outlined),
                label: const Text("Je suis un Commerçant"), // TODO: Internationaliser
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  // backgroundColor: Theme.of(context).colorScheme.secondary, // Utilisez vos couleurs de thème
                  // foregroundColor: Colors.black, // Ajustez selon le fond
                ),
                onPressed: () {
                  _navigateToSignUp(context, UserRole.commercant);
                },
              ),
              const SizedBox(height: 40),
              TextButton(
                child: const Text("Déjà un compte ? Se connecter"), // TODO: Internationaliser
                onPressed: () {
                  // Retourner à l'écran de connexion.
                  // Si LoginScreen est la route racine après Splash, on peut simplement pop.
                  // Sinon, il faut une navigation plus explicite.
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Navigator.pushReplacementNamed(context, '/login'); // Si routes nommées
                    // Pour l'instant, on suppose qu'on peut pop ou que l'utilisateur
                    // trouvera le bouton de retour de l'AppBar
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
