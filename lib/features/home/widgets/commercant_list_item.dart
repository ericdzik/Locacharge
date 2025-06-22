// lib/features/home/widgets/commercant_list_item.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/shared/styles/colors.dart';

class CommercantListItem extends StatelessWidget {
  final CommercantModel commercant;

  const CommercantListItem({
    super.key,
    required this.commercant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Text(
            commercant.nom[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          commercant.nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              commercant.localisation.adresse ?? 'Adresse non disponible',
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: commercant.services.take(3).map((service) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textLight,
          size: 16,
        ),
        onTap: () {
          context.go('/commercant/${commercant.id}');
        },
      ),
    );
  }
}
