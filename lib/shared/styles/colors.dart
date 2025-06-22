import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales panafricaines
  static const Color primaryColor = Color(0xFF174C1A); // Vert foncé
  static const Color primaryLight = Color(0xFF218838); // Vert plus clair
  static const Color primaryDark = Color(0xFF0B2E13); // Vert très foncé

  // Jaune vif pour le fond principal
  static const Color backgroundColor = Color(0xFFFFD600); // Jaune vif
  static const Color accentColor = Color(0xFFFFD600); // Jaune vif (accent)
  static const Color secondaryColor =
      Color(0xFF174C1A); // Vert foncé (pour boutons secondaires)

  // Rouge vif pour erreurs/accents
  static const Color errorColor = Color(0xFFEF4444); // Rouge vif
  static const Color warningColor = Color(0xFFFFC300); // Jaune foncé
  static const Color successColor =
      Color(0xFF10B981); // Vert succès (plus clair)
  static const Color infoColor = Color(0xFF174C1A); // Vert foncé pour info

  // Couleurs de fond et surfaces
  static const Color surfaceColor = Color(0xFFFFFFFF); // Blanc pur
  static const Color cardColor = Color(0xFFFFFFFF);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF174C1A); // Vert foncé
  static const Color textSecondary = Color(0xFF333333); // Gris foncé
  static const Color textLight = Color(0xFF757575); // Gris clair
  static const Color textInverse = Color(0xFFFFFFFF); // Blanc

  // Couleurs neutres
  static const Color grey50 = Color(0xFFF8FAFC);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E1);
  static const Color grey400 = Color(0xFF94A3B8);
  static const Color grey500 = Color(0xFF64748B);
  static const Color grey600 = Color(0xFF475569);
  static const Color grey700 = Color(0xFF334155);
  static const Color grey800 = Color(0xFF1E293B);
  static const Color grey900 = Color(0xFF0F172A);

  // Couleurs avec transparence
  static Color primaryColorWithOpacity(double opacity) =>
      primaryColor.withOpacity(opacity);

  static Color surfaceColorWithOpacity(double opacity) =>
      surfaceColor.withOpacity(opacity);

  // Gradients panafricains
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [accentColor, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, warningColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
