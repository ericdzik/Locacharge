// lib/features/admin/screens/add_edit_commercant_screen.dart
import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/horaire_model.dart'; // Pour structure horaire
import 'package:locacharge/core/services/commercant_service.dart';
// import 'package:locacharge/core/services/auth_service.dart'; // Pour créer le user Firebase Auth (TODO)
// import 'package:locacharge/core/services/user_service.dart'; // Pour créer le user Firestore (TODO)
// import 'package:locacharge/core/models/user_model.dart'; // Pour créer le user Firestore (TODO)
// import 'package:locacharge/core/models/role_enum.dart'; // Pour créer le user Firestore (TODO)


class AddEditCommercantScreen extends StatefulWidget {
  final CommercantModel? commercantToEdit; // Null pour l'ajout

  const AddEditCommercantScreen({super.key, this.commercantToEdit});

  @override
  State<AddEditCommercantScreen> createState() => _AddEditCommercantScreenState();
}

class _AddEditCommercantScreenState extends State<AddEditCommercantScreen> {
  final _formKey = GlobalKey<FormState>();
  final CommercantService _commercantService = CommercantService();
  // final AuthService _authService = AuthService(); // TODO
  // final UserService _userService = UserService(); // TODO

  late TextEditingController _nomController;
  late TextEditingController _userIdController; // UID de l'utilisateur Firebase associé
  late TextEditingController _latController;
  late TextEditingController _lonController;
  late TextEditingController _adresseController;
  late TextEditingController _telController;
  late TextEditingController _imageUrlController;
  StatutDisponibilite _statutDisponibilite = StatutDisponibilite.inconnu;
  // TODO: Gérer la saisie des horaires de manière plus conviviale

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.commercantToEdit?.nom);
    _userIdController = TextEditingController(text: widget.commercantToEdit?.id); // ID du commerçant est l'UID
    _latController = TextEditingController(text: widget.commercantToEdit?.localisation.latitude.toString());
    _lonController = TextEditingController(text: widget.commercantToEdit?.localisation.longitude.toString());
    _adresseController = TextEditingController(text: widget.commercantToEdit?.localisation.adresse);
    _telController = TextEditingController(text: widget.commercantToEdit?.telephone);
    _imageUrlController = TextEditingController(text: widget.commercantToEdit?.imageUrl);
    _statutDisponibilite = widget.commercantToEdit?.statutDisponibilite ?? StatutDisponibilite.inconnu;

    // if (widget.commercantToEdit != null && _userIdController.text.isNotEmpty) {
    //   // _userIdController.enabled = false; // Ne pas permettre de modifier l'UID si édition
    // }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _userIdController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _adresseController.dispose();
    _telController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCommercant() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userIdController.text.trim().isEmpty) {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("L'ID utilisateur (UID Firebase) est requis.")));
        return;
    }

    setState(() { _isLoading = true; });

    // SIMPLIFICATION: Création du compte Firebase Auth et du document user associé est un TODO.
    // On suppose que l'UID fourni dans _userIdController existe déjà dans Firebase Auth
    // et a un document dans la collection 'users' avec UserRole.commercant.

    final localisation = LocalisationModel(
      latitude: double.parse(_latController.text),
      longitude: double.parse(_lonController.text),
      adresse: _adresseController.text,
    );

    // TODO: Ajouter une UI pour gérer les horaires
    final horaires = widget.commercantToEdit?.horaires ?? <HoraireModel>[
        // Horaire par défaut si nouveau, à améliorer
        HoraireModel(jour: "Lundi-Vendredi", ouverture: "09:00", fermeture: "18:00")
    ];

    final commercant = CommercantModel(
      id: _userIdController.text.trim(), // UID de l'utilisateur Firebase
      nom: _nomController.text,
      localisation: localisation,
      horaires: horaires, // Horaires à gérer
      telephone: _telController.text,
      imageUrl: _imageUrlController.text,
      statutDisponibilite: _statutDisponibilite,
      estActif: widget.commercantToEdit?.estActif ?? true, // par défaut actif
    );

    try {
      await _commercantService.createOrUpdateCommercant(commercant);
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Commerçant ${widget.commercantToEdit == null ? "ajouté" : "modifié"} avec succès!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
    } finally {
      if(mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commercantToEdit == null ? 'Ajouter Commerçant' : 'Modifier Commerçant'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _userIdController,
                      decoration: const InputDecoration(labelText: 'ID Utilisateur (Firebase UID)'),
                      validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                      enabled: widget.commercantToEdit == null, // Non modifiable si édition
                    ),
                    TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom du commerçant'),
                      validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Champ requis' : (double.tryParse(value) == null ? 'Nombre invalide' : null),
                    ),
                    TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Champ requis' : (double.tryParse(value) == null ? 'Nombre invalide' : null),
                    ),
                    TextFormField(
                      controller: _adresseController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    TextFormField(
                      controller: _telController,
                      decoration: const InputDecoration(labelText: 'Téléphone'),
                    ),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(labelText: 'URL de l'image'),
                    ),
                    DropdownButtonFormField<StatutDisponibilite>(
                      value: _statutDisponibilite,
                      decoration: const InputDecoration(labelText: 'Statut de disponibilité'),
                      items: StatutDisponibilite.values.map((StatutDisponibilite statut) {
                        return DropdownMenuItem<StatutDisponibilite>(
                          value: statut,
                          child: Text(statut.toString().split('.').last),
                        );
                      }).toList(),
                      onChanged: (StatutDisponibilite? newValue) {
                        if (newValue != null) {
                          setState(() { _statutDisponibilite = newValue; });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveCommercant,
                      child: Text(widget.commercantToEdit == null ? 'Ajouter' : 'Sauvegarder'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
