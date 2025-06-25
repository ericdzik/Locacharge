import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';

class EditCommercantScreen extends StatefulWidget {
  final CommercantModel commercant;

  const EditCommercantScreen({
    super.key,
    required this.commercant,
  });

  @override
  State<EditCommercantScreen> createState() => _EditCommercantScreenState();
}

class _EditCommercantScreenState extends State<EditCommercantScreen> {
  final _formKey = GlobalKey<FormState>();
  final CommercantService _commercantService = CommercantService();

  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _telephoneController;
  late TextEditingController _emailController;
  late TextEditingController _imageUrlController;

  List<HoraireModel> _horaires = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadHoraires();
  }

  void _initializeControllers() {
    _nomController = TextEditingController(text: widget.commercant.nom);
    _descriptionController =
        TextEditingController(text: widget.commercant.description ?? '');
    _telephoneController =
        TextEditingController(text: widget.commercant.telephone ?? '');
    _emailController =
        TextEditingController(text: widget.commercant.email ?? '');
    _imageUrlController =
        TextEditingController(text: widget.commercant.imageUrl ?? '');
  }

  void _loadHoraires() {
    _horaires = List.from(widget.commercant.horaires);
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('EditCommercantScreen - Commerçant original ID: ${widget.commercant.id}, UserID: ${widget.commercant.userId}');
      final updatedCommercant = widget.commercant.copyWith(
        nom: _nomController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        telephone: _telephoneController.text.trim().isEmpty
            ? null
            : _telephoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
        horaires: _horaires,
        dateModification: DateTime.now(),
      );
      print('EditCommercantScreen - Données envoyées pour la mise à jour: ${updatedCommercant.toMap()}');

      // Remplacer par la méthode Firebase appropriée, par exemple updateCommercantFirebase
      // ou createOrUpdateCommercant si l'ID est déjà celui du document Firestore.
      // Étant donné que c'est un écran "Edit", on s'attend à ce que l'ID soit celui du document.
      await _commercantService.updateCommercantFirebase(updatedCommercant);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations mises à jour avec succès'),
            backgroundColor: AppColors.successColor,
          ),
        );
        Navigator.pop(context, true); // Retour avec succès
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editHoraire(int index) {
    showDialog(
      context: context,
      builder: (context) => _HoraireEditDialog(
        horaire: _horaires[index],
        onSave: (horaire) {
          setState(() {
            _horaires[index] = horaire;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Modifier mes informations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations générales
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations générales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nomController,
                            decoration: const InputDecoration(
                              labelText: 'Nom du point de vente',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Le nom est requis';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description (optionnel)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contact
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _telephoneController,
                            decoration: const InputDecoration(
                              labelText: 'Numéro de téléphone',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.phone),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email (optionnel)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Email invalide';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Image
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Image de la boutique',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL de l\'image',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image),
                              hintText: 'https://example.com/image.jpg',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                          if (widget.commercant.imageUrl != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(widget.commercant.imageUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Horaires
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Horaires d\'ouverture',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: AppColors.primaryColor),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _HoraireEditDialog(
                                      onSave: (horaire) {
                                        setState(() {
                                          _horaires.add(horaire);
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._horaires.asMap().entries.map((entry) {
                            final index = entry.key;
                            final horaire = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(horaire.jour),
                                subtitle: Text(
                                    '${horaire.ouverture} - ${horaire.fermeture}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: AppColors.primaryColor),
                                      onPressed: () => _editHoraire(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: AppColors.errorColor),
                                      onPressed: () {
                                        setState(() {
                                          _horaires.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bouton de sauvegarde
                    SizedBox(
                      width: double.infinity,
                      child: ModernPrimaryButton(
                        text: 'Sauvegarder les modifications',
                        onPressed: _saveChanges,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HoraireEditDialog extends StatefulWidget {
  final HoraireModel? horaire;
  final Function(HoraireModel) onSave;

  const _HoraireEditDialog({
    this.horaire,
    required this.onSave,
  });

  @override
  State<_HoraireEditDialog> createState() => _HoraireEditDialogState();
}

class _HoraireEditDialogState extends State<_HoraireEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _jourController;
  late TextEditingController _ouvertureController;
  late TextEditingController _fermetureController;

  @override
  void initState() {
    super.initState();
    _jourController = TextEditingController(text: widget.horaire?.jour ?? '');
    _ouvertureController =
        TextEditingController(text: widget.horaire?.ouverture ?? '');
    _fermetureController =
        TextEditingController(text: widget.horaire?.fermeture ?? '');
  }

  @override
  void dispose() {
    _jourController.dispose();
    _ouvertureController.dispose();
    _fermetureController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final horaire = HoraireModel(
      jour: _jourController.text.trim(),
      ouverture: _ouvertureController.text.trim(),
      fermeture: _fermetureController.text.trim(),
    );

    widget.onSave(horaire);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.horaire == null
          ? 'Ajouter un horaire'
          : 'Modifier l\'horaire'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _jourController,
              decoration: const InputDecoration(
                labelText: 'Jour(s)',
                hintText: 'Ex: Lundi-Vendredi',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le jour est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ouvertureController,
                    decoration: const InputDecoration(
                      labelText: 'Ouverture',
                      hintText: '09:00',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Heure requise';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fermetureController,
                    decoration: const InputDecoration(
                      labelText: 'Fermeture',
                      hintText: '18:00',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Heure requise';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Sauvegarder'),
        ),
      ],
    );
  }
}

