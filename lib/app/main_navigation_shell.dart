// lib/app/main_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:locacharge/features/home/screens/home_screen.dart';
import 'package:locacharge/features/home/screens/list_view_screen.dart';
import 'package:locacharge/features/account/screens/account_screen.dart';
import 'package:locacharge/core/models/commercant_model.dart'; // Pour passer les commerçants

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  // TODO: La gestion des commerçants devrait être centralisée (Provider/Bloc)
  // Pour l'instant, on simule ou on suppose qu'ils sont récupérés ici ou passés.
  // HomeScreen gère sa propre liste de commerçants actuellement.
  // ListViewScreen s'attend à recevoir une liste.
  // Cela nécessitera une refactorisation pour un état partagé.
  List<CommercantModel> _filteredCommercantsForList = [];

  // Cette méthode est un placeholder. Dans une vraie app, HomeScreen mettrait à jour
  // un état partagé (via Provider/Bloc) que ListViewScreen écouterait.
  // Ou alors, HomeScreen et ListViewScreen partageraient un ViewModel.
  void _updateFilteredCommercantsForList(List<CommercantModel> commercants) {
    if(mounted) {
      setState(() {
        _filteredCommercantsForList = commercants;
      });
    }
  }

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    // Note: HomeScreen gère ses propres données.
    // ListViewScreen a besoin des données filtrées.
    // Pour le moment, ListViewScreen dans la nav bar sera vide ou avec des données mock
    // car HomeScreen ne communique pas encore ses _filteredCommercants au shell.
    // Une solution temporaire serait de passer une callback à HomeScreen.
    // Une meilleure solution est un gestionnaire d'état.

    // Pour la démo, HomeScreen va fonctionner indépendamment.
    // ListViewScreen ici utilisera une liste vide ou mock.
    // La navigation depuis HomeScreen vers ListViewScreen (via le bouton dans l'appbar de HomeScreen)
    // fonctionnera car elle passe directement les données.
    _widgetOptions = <Widget>[
      // HomeScreen aura besoin d'une manière de communiquer sa liste filtrée au shell
      // si on veut que le ListViewScreen de la nav bar soit synchronisé sans Provider.
      // Pour l'instant, la HomeScreen de la nav bar sera indépendante.
      const HomeScreen(),
      ListViewScreen(commercants: _filteredCommercantsForList), // Initialement vide
      const AccountScreen(),
    ];
  }


  void _onItemTapped(int index) {
    if(mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'AppBar sera définie dans chaque écran individuel (_widgetOptions.elementAt(_selectedIndex))
      // pour plus de flexibilité (par exemple, HomeScreen a une AppBar avec recherche/filtres).
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Liste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Utilise la couleur primaire du thème
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        // Design inspiré: fond blanc, icônes bleu/jaune
        // backgroundColor: Colors.white, // Thème par défaut est déjà blanc généralement
        // selectedItemColor: const Color(0xFFFBAF00), // Jaune/Orangé pour sélection
        // unselectedItemColor: const Color(0xFF003B6F), // Bleu profond pour non sélectionné
      ),
    );
  }
}
