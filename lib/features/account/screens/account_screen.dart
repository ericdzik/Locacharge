// lib/features/account/screens/account_screen.dart
import 'package:flutter/material.dart';
// Import AuthService pour la déconnexion
// import 'package:locacharge/core/services/auth_service.dart';
// import 'package:provider/provider.dart'; // Si vous utilisez Provider pour AuthService
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:locacharge/shared/widgets/modern_input_fields.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final authService = Provider.of<AuthService>(context, listen: false); // Exemple avec Provider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte',
            style: TextStyle(
                color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: ModernCard(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: AppColors.primaryColor, size: 56),
              const SizedBox(height: 16),
              const Text(
                'Mon profil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Page de compte (Prochainement)',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ModernPrimaryButton(
                text: 'Déconnexion (TODO)',
                icon: Icons.logout,
                onPressed: () async {
                  // Logique de déconnexion
                  // await authService.signOut();
                  // TODO: Naviguer vers l'écran de connexion après déconnexion
                  // Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Fonctionnalité de déconnexion à implémenter.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              ModernSecondaryButton(
                text: 'Devenir commerçant',
                icon: Icons.store,
                onPressed: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (context) => _DevenirCommercantForm(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DevenirCommercantForm extends StatefulWidget {
  @override
  State<_DevenirCommercantForm> createState() => _DevenirCommercantFormState();
}

class _DevenirCommercantFormState extends State<_DevenirCommercantForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  bool _isLoading = false;
  LatLng? _selectedLatLng;

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _choisirSurCarte() async {
    final result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CarteSelectionWidget(initial: _selectedLatLng),
    );
    if (result != null) {
      setState(() {
        _selectedLatLng = result;
      });
    }
  }

  Future<void> _valider() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez choisir un emplacement sur la carte.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');
      final userId = user.uid;
      // Créer la fiche commerçant
      final commercantRef =
          FirebaseFirestore.instance.collection('commercants').doc();
      await commercantRef.set({
        'id': commercantRef.id,
        'nom': _nomController.text.trim(),
        'userId': userId,
        'localisation': {
          'adresse': _adresseController.text.trim(),
          'latitude': _selectedLatLng!.latitude,
          'longitude': _selectedLatLng!.longitude,
        },
        'dateCreation': DateTime.now(),
        'dateModification': DateTime.now(),
      });
      // Mettre à jour le rôle dans /users
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': 'UserRole.commercant',
      });
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed('/commercant/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Créer ma fiche commerçant',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ModernTextField(
              controller: _nomController,
              label: 'Nom du point de vente',
              hint: 'Ex: Boutique Chez Ali',
              validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _adresseController,
              label: 'Adresse',
              hint: 'Ex: Treichville, Rue du Commerce',
              validator: (v) =>
                  v == null || v.isEmpty ? 'Adresse requise' : null,
            ),
            const SizedBox(height: 16),
            ModernSecondaryButton(
              text: _selectedLatLng == null
                  ? 'Choisir sur la carte'
                  : "Modifier l'emplacement",
              icon: Icons.map,
              onPressed: _choisirSurCarte,
            ),
            if (_selectedLatLng != null) ...[
              const SizedBox(height: 8),
              Text(
                'Emplacement choisi :\nLat: ${_selectedLatLng!.latitude.toStringAsFixed(5)}, Lng: ${_selectedLatLng!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 28),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ModernPrimaryButton(
                    text: 'Valider',
                    icon: Icons.check,
                    onPressed: _valider,
                  ),
          ],
        ),
      ),
    );
  }
}

// Widget de sélection sur carte
class _CarteSelectionWidget extends StatefulWidget {
  final LatLng? initial;
  const _CarteSelectionWidget({this.initial});

  @override
  State<_CarteSelectionWidget> createState() => _CarteSelectionWidgetState();
}

class _CarteSelectionWidgetState extends State<_CarteSelectionWidget> {
  LatLng? _selected;
  final LatLng _defaultCenter = const LatLng(5.3454, -4.0245); // Abidjan

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Cliquez sur la carte pour placer le point',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _selected ?? _defaultCenter,
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  setState(() {
                    _selected = latlng;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ModernPrimaryButton(
              text: 'Valider cet emplacement',
              icon: Icons.check,
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}
