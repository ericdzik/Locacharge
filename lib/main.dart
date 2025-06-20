// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:locacharge/firebase_options.dart';
import 'package:locacharge/app/main_navigation_shell.dart'; // Importer le shell
// import 'package:locacharge/features/auth/screens/login_screen.dart'; // Pour la logique d'auth
// import 'package:locacharge/core/services/auth_service.dart'; // Pour vérifier l'état d'auth
// import 'package:provider/provider.dart'; // Si vous utilisez Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // TODO: Mettre en place Provider pour les services si nécessaire
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       Provider<AuthService>(create: (_) => AuthService()),
  //       // Autres providers...
  //     ],
  //     child: const MyApp(),
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context); // Exemple avec Provider
    return MaterialApp(
      title: 'LocaCharge',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Sera personnalisé plus tard
        // Définir les couleurs principales ici selon la maquette
        primaryColor: const Color(0xFF003B6F), // Bleu profond
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFFBAF00), // Jaune/orangé vif pour les accents (FAB, etc.)
          background: Colors.white, // Fond principal
        ),
        scaffoldBackgroundColor: Colors.white, // Fond pour Scaffold
        // Personnaliser d'autres aspects du thème si nécessaire
        // appBarTheme: const AppBarTheme(
        //   backgroundColor: Color(0xFF003B6F), // Bleu profond pour AppBar
        //   foregroundColor: Colors.white, // Texte et icônes en blanc sur AppBar
        // ),
        // textTheme: ...,
        // iconTheme: ...,
      ),
      // home: authService.currentUser == null ? const LoginScreen() : const MainNavigationShell(), // Exemple avec logique d'auth
      home: const MainNavigationShell(), // Directement vers le shell pour l'instant
      // Définir les routes si vous utilisez la navigation nommée pour le login, etc.
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/home': (context) => const MainNavigationShell(),
      //   // ... autres routes
      // },
    );
  }
}
