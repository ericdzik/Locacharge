// lib/features/auth/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/role_enum.dart'; // Importer UserRole
import '../widgets/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  final UserRole role; // Ajouter le paramètre role

  const SignUpScreen({super.key, required this.role}); // Mettre à jour le constructeur

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription ${role == UserRole.commercant ? 'Commerçant' : 'Client'}")), // Titre dynamique
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SignUpForm(role: role), // Passer le rôle au formulaire
      ),
    );
  }
}
