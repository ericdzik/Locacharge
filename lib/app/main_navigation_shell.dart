// lib/app/main_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/features/home/screens/home_screen.dart';
import 'package:locacharge/features/home/screens/list_view_screen.dart';
import 'package:locacharge/features/account/screens/account_screen.dart';
import 'package:locacharge/core/models/commercant_model.dart'; // Pour passer les commerçants

class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          NavigationDestination(
            icon: Icon(Icons.help),
            label: 'Aide',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        indicatorColor: AppColors.primaryColor.withOpacity(0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
