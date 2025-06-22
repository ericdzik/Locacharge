import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/services/commercant_service.dart';

class HistoryService {
  static const String _favoritesKey = 'favorites';
  static const String _recentVisitsKey = 'recent_visits';
  static const String _recentSearchesKey = 'recent_searches';

  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  // Gestion des favoris
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> addFavorite(String commercantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    if (!favorites.contains(commercantId)) {
      favorites.add(commercantId);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  Future<void> removeFavorite(String commercantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.remove(commercantId);
    await prefs.setStringList(_favoritesKey, favorites);
  }

  Future<bool> isFavorite(String commercantId) async {
    final favorites = await getFavorites();
    return favorites.contains(commercantId);
  }

  // Gestion des visites récentes
  Future<List<String>> getRecentVisits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentVisitsKey) ?? [];
  }

  Future<void> addRecentVisit(String commercantId) async {
    final prefs = await SharedPreferences.getInstance();
    final visits = await getRecentVisits();

    // Retirer si déjà présent pour éviter les doublons
    visits.remove(commercantId);

    // Ajouter au début de la liste
    visits.insert(0, commercantId);

    // Garder seulement les 20 dernières visites
    if (visits.length > 20) {
      visits.removeRange(20, visits.length);
    }

    await prefs.setStringList(_recentVisitsKey, visits);
  }

  // Gestion des recherches récentes
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> addRecentSearch(String searchTerm) async {
    if (searchTerm.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();

    // Retirer si déjà présent
    searches.remove(searchTerm);

    // Ajouter au début
    searches.insert(0, searchTerm);

    // Garder seulement les 10 dernières recherches
    if (searches.length > 10) {
      searches.removeRange(10, searches.length);
    }

    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> removeRecentSearch(String searchTerm) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();
    searches.remove(searchTerm);
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }

  // Méthodes utilitaires pour charger les données complètes
  Future<List<CommercantModel>> getFavoriteCommercants(
      CommercantService commercantService) async {
    final favoriteIds = await getFavorites();
    final commercants = <CommercantModel>[];

    for (final id in favoriteIds) {
      final commercant = await commercantService.getCommercantById(id);
      if (commercant != null) {
        commercants.add(commercant);
      }
    }

    return commercants;
  }

  Future<List<CommercantModel>> getRecentVisitCommercants(
      CommercantService commercantService) async {
    final visitIds = await getRecentVisits();
    final commercants = <CommercantModel>[];

    for (final id in visitIds) {
      final commercant = await commercantService.getCommercantById(id);
      if (commercant != null) {
        commercants.add(commercant);
      }
    }

    return commercants;
  }

  // Nettoyage des données obsolètes
  Future<void> cleanupOldData() async {
    final prefs = await SharedPreferences.getInstance();
    final visits = await getRecentVisits();
    final searches = await getRecentSearches();

    // Supprimer les recherches vides
    searches.removeWhere((search) => search.trim().isEmpty);

    await prefs.setStringList(_recentSearchesKey, searches);
  }
}
