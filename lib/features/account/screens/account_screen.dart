// lib/features/account/screens/account_screen.dart
import 'package:flutter/material.dart';
// Import AuthService pour la déconnexion
// import 'package:locacharge/core/services/auth_service.dart';
// import 'package:provider/provider.dart'; // Si vous utilisez Provider pour AuthService

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context, listen: false); // Exemple avec Provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page de compte (Prochainement)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Logique de déconnexion
                // await authService.signOut();
                // TODO: Naviguer vers l'écran de connexion après déconnexion
                // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                 if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fonctionnalité de déconnexion à implémenter.')),
                    );
                  }
              },
              child: const Text('Déconnexion (TODO)'),
            ),
          ],
        ),
      ),
    );
  }
}
