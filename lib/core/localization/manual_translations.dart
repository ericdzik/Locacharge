// lib/core/localization/manual_translations.dart
import 'package:flutter/material.dart'; // Pour Locale

class ManualTranslations {
  Locale _currentLocale;

  // Constructeur, initialiser avec une locale par défaut ou la locale de l'appareil
  ManualTranslations(this._currentLocale);

  // Méthode pour changer la locale active
  void setLocale(Locale locale) {
    _currentLocale = locale;
    // Ici, dans une application plus grande avec un gestionnaire d'état,
    // on notifierait les auditeurs du changement de locale pour reconstruire l'UI.
    // Pour l'instant, le changement sera manuel ou au redémarrage de l'écran.
  }

  Locale get currentLocale => _currentLocale;

  static final Map<String, String> _en = {
    'appTitle': 'LocaCharge',
    'searchHintText': 'Search for a shop, district or city...',
    'homeScreenTitle': 'LocaCharge Map', // Ajout pour exemple
    'listScreenTitle': 'Charging Points List', // Ajout pour exemple
    'accountScreenTitle': 'My Account', // Ajout pour exemple
    'merchantDashboardTitle': 'Merchant Dashboard', // Ajout pour exemple
    'adminDashboardTitle': 'Admin Dashboard', // Ajout pour exemple
    // ... autres clés
  };

  static final Map<String, String> _fr = {
    'appTitle': 'LocaCharge',
    'searchHintText': 'Rechercher une boutique, un quartier ou une ville...',
    'homeScreenTitle': 'LocaCharge Carte',
    'listScreenTitle': 'Liste des Points de Recharge',
    'accountScreenTitle': 'Mon Compte',
    'merchantDashboardTitle': 'Tableau de Bord Commerçant',
    'adminDashboardTitle': 'Tableau de Bord Admin',
    // ... autres clés
  };

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'fr': _fr,
  };

  String translate(String key) {
    // Utiliser la langue de _currentLocale, avec fallback sur 'en' si la langue n'est pas supportée
    final langCode = _currentLocale.languageCode;
    final mapForLocale = _localizedValues[langCode];

    if (mapForLocale != null && mapForLocale.containsKey(key)) {
      return mapForLocale[key]!;
    }
    // Fallback sur l'anglais si la clé n'est pas trouvée dans la locale actuelle
    // ou si la locale n'est pas 'fr' (seule autre langue définie pour l'instant)
    if (_localizedValues['en']!.containsKey(key)) {
      return _localizedValues['en']![key]!;
    }
    // Fallback ultime si la clé n'est trouvée nulle part
    return key; // ou 'Key $key not found'
  }

  // Méthode statique pratique pour un accès plus facile si on utilise un singleton ou Provider
  // Pour l'instant, on instanciera la classe.
  // static ManualTranslations? _instance;
  // static ManualTranslations get instance {
  //   _instance ??= ManualTranslations(const Locale('fr')); // Locale par défaut
  //   return _instance!;
  // }
  // String call(String key) => translate(key); // Permet d'appeler l'instance comme une fonction
}

// Exemple d'une classe "Provider" très basique si on ne veut pas utiliser le package Provider tout de suite
// Ou un simple singleton global pour un accès facile.
// Pour cette étape, on se contentera de la classe ManualTranslations elle-même.
// L'instanciation et la gestion de la locale active seront faites dans les widgets pour l'instant.
