// lib/features/home/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour SystemChannels
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:locacharge/core/config/app_config.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/horaire_model.dart'; // Import HoraireModel
import 'package:locacharge/core/models/produit_model.dart'; // Import ProduitModel
import 'package:locacharge/core/services/commercant_service.dart'; // Import CommercantService
import 'package:locacharge/core/services/history_service.dart'; // Import HistoryService
import 'package:locacharge/features/home/screens/list_view_screen.dart'; // Import ListViewScreen
import 'package:locacharge/shared/styles/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:locacharge/shared/widgets/modern_input_fields.dart';
// Pour l'internationalisation (exemple)
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapController? _mapController;
  LatLng _initialCameraPosition = const LatLng(5.3454, -4.0245); // Abidjan
  bool _myLocationEnabled = false;

  final CommercantService _commercantService = CommercantService();
  final HistoryService _historyService = HistoryService();
  List<CommercantModel> _commercants = [];
  List<CommercantModel> _filteredCommercants = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Nouveaux états de filtre pour les checkboxes
  final Map<String, bool> _filters = {
    'recharge': false,
    'transfert': false,
    'sim': false,
    'ouvert': false,
  };

  bool _isLoading = true;
  String _selectedFilter = 'Tous';

  final List<String> _filtersList = [
    'Tous',
    'Recharge',
    'Services',
    'Proximité'
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _requestLocationPermission();
    _applyFiltersAndSearch(); // Charger initialement les données
    _searchController.addListener(_onSearchChanged);
    _loadCommercants();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (mounted &&
        (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always)) {
      setState(() => _myLocationEnabled = true);
      _getCurrentLocationAndCenterMap();
    }
  }

  Future<void> _getCurrentLocationAndCenterMap() async {
    if (!_myLocationEnabled || _mapController == null) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _mapController?.move(LatLng(position.latitude, position.longitude), 14.0);
    } catch (e) {
      print("Erreur de géolocalisation: $e");
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce =
        Timer(const Duration(milliseconds: 500), _applyFiltersAndSearch);
  }

  Future<void> _applyFiltersAndSearch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      List<TypeProduit> typesProduit = [];
      if (_filters['recharge']!)
        typesProduit.add(TypeProduit.rechargeTelephonique);
      if (_filters['transfert']!) typesProduit.add(TypeProduit.mobileMoney);

      List<String> services = [];
      if (_filters['sim']!) services.add('sim');

      final commercants = await _commercantService.searchCommercants(
        query: _searchController.text.isEmpty ? null : _searchController.text,
        estOuvert: _filters['ouvert']! ? true : null,
        typesProduit: typesProduit,
        services: services,
      );

      // Sauvegarder la recherche si elle n'est pas vide
      if (_searchController.text.trim().isNotEmpty) {
        await _historyService.addRecentSearch(_searchController.text.trim());
      }

      if (mounted) {
        setState(() {
          _commercants = commercants;
          _filteredCommercants = commercants;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de l'application des filtres: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialCameraPosition,
        initialZoom: 11.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(markers: _buildMarkers()),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    return _filteredCommercants.map((commercant) {
      return Marker(
        point: LatLng(commercant.localisation.latitude,
            commercant.localisation.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () {/* Afficher les détails */},
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(_getIconForCommercantType(commercant.typeCommercant),
                color: Colors.white, size: 20),
          ),
        ),
      );
    }).toList();
  }

  IconData _getIconForCommercantType(TypeCommercant type) {
    switch (type) {
      case TypeCommercant.boutique:
        return Icons.store;
      case TypeCommercant.kiosque:
        return Icons.widgets;
      case TypeCommercant.stationService:
        return Icons.local_gas_station;
      case TypeCommercant.pharmacie:
        return Icons.local_pharmacy;
      case TypeCommercant.supermarche:
        return Icons.shopping_cart;
      default:
        return Icons.location_pin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header moderne avec gradient
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LocaCharge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Trouvez des points de recharge près de chez vous',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        ModernIconButton(
                          icon: Icons.person,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          iconColor: Colors.white,
                          onPressed: () => context.go('/account'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ModernSearchField(
                      hint: 'Rechercher un commerçant...',
                      controller: _searchController,
                      onChanged: _searchCommercants,
                    ),
                  ],
                ),
              ),
            ),

            // Filtres modernes
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filtersList.length,
                itemBuilder: (context, index) {
                  final filter = _filtersList[index];
                  final isSelected = _selectedFilter == filter;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => _filterCommercants(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient:
                              isSelected ? AppColors.primaryGradient : null,
                          color: isSelected ? null : AppColors.surfaceColor,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : AppColors.grey200,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: AppColors.grey200.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Contenu principal
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                    )
                  : _filteredCommercants.isEmpty
                      ? _buildEmptyState()
                      : _buildCommercantsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        icon: Icons.my_location,
        onPressed: () {
          // Action pour localiser l'utilisateur
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun commerçant trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos critères de recherche',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCommercantsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredCommercants.length,
      itemBuilder: (context, index) {
        final commercant = _filteredCommercants[index];
        final isOpen = commercant.estOuvertMaintenant;

        return ModernCard(
          onTap: () {
            context.go('/commercant/${commercant.id}');
          },
          child: Row(
            children: [
              // Avatar du commerçant
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.store,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Informations du commerçant
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commercant.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            commercant.localisation.adresse ??
                                'Adresse non disponible',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: commercant.services.take(3).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Statut et distance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen
                          ? AppColors.successColor.withOpacity(0.1)
                          : AppColors.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isOpen ? 'Ouvert' : 'Fermé',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOpen
                            ? AppColors.successColor
                            : AppColors.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(index + 1) * 0.5} km',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadCommercants() async {
    try {
      final commercants = await _commercantService.getAllCommercants();
      setState(() {
        _commercants = commercants;
        _filteredCommercants = commercants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement des commerçants');
    }
  }

  Future<void> _loadRecentSearches() async {
    // Méthode non nécessaire pour le moment
  }

  void _filterCommercants(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Tous') {
        _filteredCommercants = _commercants;
      } else if (filter == 'Recharge') {
        _filteredCommercants =
            _commercants.where((c) => c.services.contains('Recharge')).toList();
      } else if (filter == 'Services') {
        _filteredCommercants =
            _commercants.where((c) => c.services.contains('Services')).toList();
      } else if (filter == 'Proximité') {
        // Tri par distance (simulation)
        _filteredCommercants = List.from(_commercants)
          ..sort((a, b) => a.nom.compareTo(b.nom));
      }
    });
  }

  void _searchCommercants(String query) {
    if (query.isEmpty) {
      _filterCommercants(_selectedFilter);
    } else {
      setState(() {
        _filteredCommercants = _commercants
            .where((commercant) =>
                commercant.nom.toLowerCase().contains(query.toLowerCase()) ||
                (commercant.localisation.adresse?.toLowerCase() ?? '')
                    .contains(query.toLowerCase()) ||
                commercant.services.any((service) =>
                    service.toLowerCase().contains(query.toLowerCase())))
            .toList();
      });

      // Sauvegarder la recherche
      if (query.isNotEmpty) {
        _historyService.addRecentSearch(query);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
