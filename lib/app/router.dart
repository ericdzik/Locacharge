import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/app/main_navigation_shell.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/features/account/screens/account_screen.dart';
import 'package:locacharge/features/admin/screens/admin_dashboard_screen.dart';
import 'package:locacharge/features/auth/screens/login_screen.dart';
import 'package:locacharge/features/auth/screens/splash_screen.dart';
import 'package:locacharge/features/commercant/screens/dashboard_commercant_screen.dart';
import 'package:locacharge/features/home/screens/fiche_commercant_screen.dart';
import 'package:locacharge/features/home/screens/help_screen.dart';
import 'package:locacharge/features/home/screens/history_screen.dart';
import 'package:locacharge/features/home/screens/home_screen.dart';
import 'package:locacharge/features/home/screens/list_view_screen.dart';
import 'package:locacharge/features/auth/screens/signup_screen.dart';
import 'package:locacharge/features/home/screens/navigation_screen.dart';
import 'package:locacharge/core/services/commercant_service.dart';

// Clé de navigation globale pour le shell
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Route de SplashScreen en dehors du Shell
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    // Route de Login en dehors du Shell
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Route d'inscription en dehors du Shell
    GoRoute(
      path: '/register',
      builder: (context, state) => const SignupScreen(),
    ),
    // Route du dashboard admin en dehors du Shell
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    // Route du dashboard commercant en dehors du Shell
    GoRoute(
      path: '/commercant/dashboard',
      builder: (context, state) => const DashboardCommercantScreen(),
    ),
    // Shell pour la navigation principale (avec barre de navigation)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // Branche "Accueil"
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey,
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: HomeScreen()),
              routes: [
                // Sous-route pour la fiche détaillée
                GoRoute(
                  path: 'commercant/:id',
                  builder: (context, state) {
                    final commercantId = state.pathParameters['id']!;
                    return FicheCommercantScreen(commercantId: commercantId);
                  },
                ),
                // Sous-route pour la navigation
                GoRoute(
                  path: 'navigation/:id',
                  builder: (context, state) {
                    final commercantId = state.pathParameters['id']!;
                    return FutureBuilder<CommercantModel?>(
                      future:
                          CommercantService().getCommercantById(commercantId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Scaffold(
                            body: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return const Scaffold(
                            body: Center(child: Text('Commerçant non trouvé')),
                          );
                        }
                        return NavigationScreen(commercant: snapshot.data!);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        // Branche "Historique"
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Branche "Aide"
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/help',
              builder: (context, state) => const HelpScreen(),
            ),
          ],
        ),
        // Branche "Mon Profil"
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
