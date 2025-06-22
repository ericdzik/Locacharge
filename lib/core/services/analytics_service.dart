import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'analytics';

  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  /// Enregistre une vue de profil commerçant
  Future<void> recordCommercantView(String commercantId, String? userId) async {
    try {
      final analyticsData = {
        'commercantId': commercantId,
        'userId': userId,
        'eventType': 'profile_view',
        'timestamp': FieldValue.serverTimestamp(),
        'date':
            DateTime.now().toIso8601String().split('T')[0], // Date seulement
      };

      await _firestore.collection(_collectionPath).add(analyticsData);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la vue: $e');
      // Ne pas faire échouer l'application si l'analytics échoue
    }
  }

  /// Récupère le nombre de vues pour un commerçant
  Future<int> getCommercantViews(String commercantId, {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('commercantId', isEqualTo: commercantId)
          .where('eventType', isEqualTo: 'profile_view')
          .where('timestamp', isGreaterThanOrEqualTo: startDate)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Erreur lors de la récupération des vues: $e');
      return 0;
    }
  }

  /// Récupère les statistiques détaillées pour un commerçant
  Future<Map<String, dynamic>> getCommercantStats(String commercantId) async {
    try {
      final now = DateTime.now();
      final last30Days = now.subtract(const Duration(days: 30));
      final last7Days = now.subtract(const Duration(days: 7));
      final today = DateTime(now.year, now.month, now.day);

      // Vues des 30 derniers jours
      final views30Days = await _firestore
          .collection(_collectionPath)
          .where('commercantId', isEqualTo: commercantId)
          .where('eventType', isEqualTo: 'profile_view')
          .where('timestamp', isGreaterThanOrEqualTo: last30Days)
          .get();

      // Vues des 7 derniers jours
      final views7Days = await _firestore
          .collection(_collectionPath)
          .where('commercantId', isEqualTo: commercantId)
          .where('eventType', isEqualTo: 'profile_view')
          .where('timestamp', isGreaterThanOrEqualTo: last7Days)
          .get();

      // Vues d'aujourd'hui
      final viewsToday = await _firestore
          .collection(_collectionPath)
          .where('commercantId', isEqualTo: commercantId)
          .where('eventType', isEqualTo: 'profile_view')
          .where('date', isEqualTo: today.toIso8601String().split('T')[0])
          .get();

      return {
        'totalViews30Days': views30Days.docs.length,
        'totalViews7Days': views7Days.docs.length,
        'viewsToday': viewsToday.docs.length,
        'averageViewsPerDay': views30Days.docs.length / 30,
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return {
        'totalViews30Days': 0,
        'totalViews7Days': 0,
        'viewsToday': 0,
        'averageViewsPerDay': 0,
      };
    }
  }

  /// Enregistre un événement de recherche
  Future<void> recordSearch(String searchTerm, String? userId) async {
    try {
      final analyticsData = {
        'searchTerm': searchTerm,
        'userId': userId,
        'eventType': 'search',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionPath).add(analyticsData);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la recherche: $e');
    }
  }

  /// Enregistre un clic sur un commerçant depuis la recherche
  Future<void> recordCommercantClick(
      String commercantId, String? userId, String? searchTerm) async {
    try {
      final analyticsData = {
        'commercantId': commercantId,
        'userId': userId,
        'searchTerm': searchTerm,
        'eventType': 'commercant_click',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(_collectionPath).add(analyticsData);
    } catch (e) {
      print('Erreur lors de l\'enregistrement du clic: $e');
    }
  }

  /// Récupère les termes de recherche populaires
  Future<List<Map<String, dynamic>>> getPopularSearches(
      {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('eventType', isEqualTo: 'search')
          .orderBy('timestamp', descending: true)
          .limit(100) // Limiter pour éviter les problèmes de performance
          .get();

      final Map<String, int> searchCounts = {};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final searchTerm = data['searchTerm'] as String?;
        if (searchTerm != null) {
          searchCounts[searchTerm] = (searchCounts[searchTerm] ?? 0) + 1;
        }
      }

      final sortedSearches = searchCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSearches
          .take(limit)
          .map((entry) => {
                'term': entry.key,
                'count': entry.value,
              })
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des recherches populaires: $e');
      return [];
    }
  }
}
