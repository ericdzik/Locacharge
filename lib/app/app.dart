import 'package:flutter/material.dart';
import 'router.dart';

class LocaChargeApp extends StatelessWidget {
  const LocaChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  routes: appRoutes, // 👈 routes correctement connectées
  initialRoute: '/', // 👈 démarre sur SplashScreen
  title: 'LocaCharge',
  theme: ThemeData(primarySwatch: Colors.green),
);

  }
}

