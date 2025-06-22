import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';

class LocaChargeApp extends StatelessWidget {
  const LocaChargeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'LocaCharge',
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
