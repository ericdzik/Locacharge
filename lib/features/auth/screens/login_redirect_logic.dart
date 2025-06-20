// lib/features/auth/screens/login_redirect_logic.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locacharge/core/models/role_enum.dart';
import 'package:locacharge/core/services/user_service.dart';
import 'package:locacharge/features/commercant/screens/dashboard_commercant_screen.dart';
import 'package:locacharge/app/main_navigation_shell.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart'; // NOUVEAU

class LoginRedirectLogic {
  static Future<void> handleLoginSuccess(BuildContext context, User firebaseUser, UserService userService) async {
    try {
      final userModel = await userService.getUserById(firebaseUser.uid);

      if (userModel == null) {
        if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Erreur: Profil utilisateur non trouvé.")),
          );
        }
        // TODO: Rediriger vers une page de création de profil ou de login
        return;
      }

      if (!context.mounted) return; // Vérifier avant toute navigation

      if (userModel.role == UserRole.admin) { // NOUVELLE CONDITION
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else if (userModel.role == UserRole.commercant) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardCommercantScreen()),
        );
      } else { // Client
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationShell()),
        );
      }
    } catch (e) {
       if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur de redirection: $e")),
          );
       }
    }
  }
}
