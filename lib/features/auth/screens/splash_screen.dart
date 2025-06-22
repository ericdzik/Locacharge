import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs et polices basées sur la nouvelle maquette du splash screen
    const Color primaryGreen = Color(0xFF00582F); // Vert foncé pour le fond
    const Color textCream = Color(0xFFF5F5DC); // Crème pour le texte principal
    const Color logoYellow = Color(0xFFFBC02D); // Jaune pour le texte "AFRICA"

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // --- Logo Principal (Placeholder) ---
              // Un logo SVG ou une image serait idéal ici.
              // En attendant, je recrée une version simplifiée.
              CircleAvatar(
                radius: 65,
                backgroundColor:
                    const Color(0xFF00753E), // Vert un peu plus clair
                child: const Icon(Icons.sim_card_outlined,
                    color: textCream, size: 70),
              ),
              const SizedBox(height: 30),

              // --- Texte Principal ---
              const Text(
                'MONEY &',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily:
                      'Roboto', // Remplacer par la police de la maquette si disponible
                  color: textCream,
                  fontSize: 42,
                  fontWeight: FontWeight.w900, // Très gras
                  height: 1.0,
                ),
              ),
              const Text(
                'CHARGE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: textCream,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'AFRICA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: logoYellow,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- Slogan ---
              const Text(
                'Ton credit, pres de toi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textCream,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const Spacer(flex: 2),

              // --- Logo bas de page (Placeholder) ---
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Placeholder pour le logo "L7"
                  Icon(Icons.layers, color: logoYellow, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'by Legrand Innovation',
                    style: TextStyle(
                      color: textCream,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
