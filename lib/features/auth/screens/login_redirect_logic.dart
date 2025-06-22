// lib/features/auth/screens/login_redirect_logic.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/core/models/role_enum.dart';
import 'package:locacharge/core/services/user_service.dart';
import 'package:locacharge/features/commercant/screens/dashboard_commercant_screen.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart';

class LoginRedirectLogic {
  static Future<void> handleLoginSuccess(
      BuildContext context, User firebaseUser, UserService userService) async {
    try {
      final userModel = await userService.getUserById(firebaseUser.uid);

      if (userModel == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Erreur: Profil utilisateur non trouvé.")),
          );
        }
        // Rediriger vers la page de login en cas d'erreur
        if (context.mounted) {
          context.go('/login');
        }
        return;
      }

      if (!context.mounted) return; // Vérifier avant toute navigation

      // Utiliser GoRouter pour la navigation
      if (userModel.role == UserRole.admin) {
        context.go('/admin/dashboard');
      } else if (userModel.role == UserRole.commercant) {
        context.go('/commercant/dashboard');
      } else {
        // Client - rediriger vers l'accueil principal
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur de redirection: $e")),
        );
      }
    }
  }
}
