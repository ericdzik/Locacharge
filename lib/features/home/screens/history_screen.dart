import 'package:flutter/material.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/history_service.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:go_router/go_router.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HistoryService _historyService = HistoryService();
  final CommercantService _commercantService = CommercantService();

  List<String> _recentSearches = [];
  List<CommercantModel> _recentVisits = [];
  List<CommercantModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final searches = await _historyService.getRecentSearches();
      final visits =
          await _historyService.getRecentVisitCommercants(_commercantService);
      final favorites =
          await _historyService.getFavoriteCommercants(_commercantService);

      setState(() {
        _recentSearches = searches;
        _recentVisits = visits;
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Historique'),
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primaryColor,
          tabs: const [
            Tab(text: 'Recherches'),
            Tab(text: 'Visites'),
            Tab(text: 'Favoris'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRecentSearchesTab(),
                _buildRecentVisitsTab(),
                _buildFavoritesTab(),
              ],
            ),
    );
  }

  Widget _buildRecentSearchesTab() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Text(
          'Aucune recherche récente',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentSearches.length,
      itemBuilder: (context, index) {
        final search = _recentSearches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.search, color: AppColors.primaryColor),
            title: Text(
              search,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await _historyService.removeRecentSearch(search);
                _loadData();
              },
            ),
            onTap: () {
              // Relancer la recherche
            },
          ),
        );
      },
    );
  }

  Widget _buildRecentVisitsTab() {
    if (_recentVisits.isEmpty) {
      return const Center(
        child: Text(
          'Aucune visite récente',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentVisits.length,
      itemBuilder: (context, index) {
        final commercant = _recentVisits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              commercant.localisation.adresse ?? 'Adresse non disponible',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () {
              context.go('/home/commercant/${commercant.id}');
            },
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return const Center(
        child: Text(
          'Aucun favori',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final commercant = _favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
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
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              commercant.localisation.adresse ?? 'Adresse non disponible',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () async {
                await _historyService.removeFavorite(commercant.id);
                _loadData();
              },
            ),
            onTap: () {
              context.go('/home/commercant/${commercant.id}');
            },
          ),
        );
      },
    );
  }
}
