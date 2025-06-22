import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';

class ProductManagementScreen extends StatefulWidget {
  final CommercantModel commercant;

  const ProductManagementScreen({
    super.key,
    required this.commercant,
  });

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Gestion des produits'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ModernCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: AppColors.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Fonctionnalité en cours de développement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'La gestion des produits sera bientôt disponible. Vous pourrez ajouter, modifier et gérer le stock de vos produits numériques.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ModernCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits actuels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.commercant.produits.length} produit(s) configuré(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.commercant.produits.where((p) => p.estDisponible).length} disponible(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
