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

    String? query = _searchController.text.trim().isEmpty ? null : _searchController.text.trim();
    List<TypeProduit>? filterTypesProduit;
    List<String>? filterServices;
    bool? filterEstOuvert;

    // Appliquer les filtres rapides basés sur _selectedFilter
    switch (_selectedFilter) {
      case 'Recharge':
        filterTypesProduit = [TypeProduit.rechargeTelephonique];
        break;
      case 'Services': // Exemple: pourrait être Mobile Money ou autres services spécifiques
        // Pour l'instant, interprétons "Services" comme "Mobile Money" pour la démo
        filterTypesProduit = [TypeProduit.mobileMoney];
        // Ou si vous avez un champ 'services' textuel:
        // filterServices = ['Mobile Money']; // exemple
        break;
      // Le filtre 'Proximité' sera géré par le tri après la récupération
      // Le filtre 'Tous' n'ajoute pas de filtres spécifiques ici
    }

    // Appliquer les filtres avancés (ceux de la map _filters)
    // Ces filtres s'ajoutent ou surchargent ceux des filtres rapides si définis
    List<TypeProduit> advancedTypesProduit = [];
    if (_filters['recharge']!) advancedTypesProduit.add(TypeProduit.rechargeTelephonique);
    if (_filters['transfert']!) advancedTypesProduit.add(TypeProduit.mobileMoney);
    // Combiner avec filterTypesProduit si nécessaire, ou laisser l'UI des filtres avancés être la source principale
    if (advancedTypesProduit.isNotEmpty) {
      filterTypesProduit = filterTypesProduit == null ? [] : List.from(filterTypesProduit);
      filterTypesProduit.addAll(advancedTypesProduit);
      filterTypesProduit = filterTypesProduit.toSet().toList(); // Dédoublonner
    }

    List<String> advancedServices = [];
    if (_filters['sim']!) advancedServices.add('vente de sim'); // Exemple de service
    if (advancedServices.isNotEmpty) {
       filterServices = filterServices == null ? [] : List.from(filterServices);
       filterServices.addAll(advancedServices);
       filterServices = filterServices.toSet().toList();
    }

    if (_filters['ouvert']!) {
      filterEstOuvert = true;
    }

    try {
      List<CommercantModel> commercants = await _commercantService.searchCommercants(
        query: query,
        estOuvert: filterEstOuvert,
        typesProduit: filterTypesProduit,
        services: filterServices,
        userLocation: _userLocation, // Passer la localisation pour le tri par proximité si besoin
      );

      // Tri par proximité si ce filtre est sélectionné
      if (_selectedFilter == 'Proximité' && _userLocation != null) {
        commercants.sort((a, b) {
          final distA = _calculateDistanceForCommercant(a);
          final distB = _calculateDistanceForCommercant(b);
          if (distA < 0 && distB < 0) return 0; // Les deux distances non calculables
          if (distA < 0) return 1; // a après b si sa distance n'est pas calculable
          if (distB < 0) return -1; // b après a si sa distance n'est pas calculable
          return distA.compareTo(distB);
        });
      }

      if (mounted) {
        setState(() {
          // Note: _commercants devrait idéalement contenir TOUS les commerçants sans filtres
          // pour pouvoir réappliquer des filtres différents sans re-fetch.
          // Ici, on met à jour _commercants et _filteredCommercants avec le résultat.
          // Cela pourrait être optimisé si _commercants reste la source de vérité complète.
          // Pour l'instant, on simplifie :
          _commercants = commercants; // Attention: cela remplace la liste complète
          _filteredCommercants = commercants;
          _isLoading = false;
        });
      }

      // Sauvegarder la recherche si une query textuelle a été utilisée
      if (query != null && query.isNotEmpty) {
        await _historyService.addRecentSearch(query);
      }

    } catch (e) {
      print("Erreur lors de l'application des filtres: $e");
      if (mounted) setState(() => _isLoading = false);
      _showErrorSnackBar("Erreur lors de la recherche: ${e.toString()}");
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
          onTap: () {
            context.go('/home/commercant/${commercant.id}');
          },
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
              child: Column(
                children: [
                  _buildAdvancedFiltersExpansionTile(), // Ajout du panneau de filtres
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
          ],
        ),
      ),
      floatingActionButton: ModernFloatingActionButton(
        icon: Icons.my_location,
        onPressed: _getCurrentLocationAndCenterMap,
      ),
    );
  }

  Widget _buildAdvancedFiltersExpansionTile() {
    return ExpansionTile(
      title: const Text('Filtres avancés', style: TextStyle(color: AppColors.textPrimary)),
      leading: const Icon(Icons.filter_list, color: AppColors.primaryColor),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: <Widget>[
        CheckboxListTile(
          title: const Text('Recharge disponible'),
          value: _filters['recharge'],
          onChanged: (bool? value) {
            setState(() {
              _filters['recharge'] = value!;
            });
            _applyFiltersAndSearch();
          },
          activeColor: AppColors.primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Transfert Mobile Money disponible'),
          value: _filters['transfert'],
          onChanged: (bool? value) {
            setState(() {
              _filters['transfert'] = value!;
            });
            _applyFiltersAndSearch();
          },
          activeColor: AppColors.primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Vente de SIM disponible'),
          value: _filters['sim'],
          onChanged: (bool? value) {
            setState(() {
              _filters['sim'] = value!;
            });
            _applyFiltersAndSearch();
          },
          activeColor: AppColors.primaryColor,
        ),
        CheckboxListTile(
          title: const Text('Ouvert actuellement'),
          value: _filters['ouvert'],
          onChanged: (bool? value) {
            setState(() {
              _filters['ouvert'] = value!;
            });
            _applyFiltersAndSearch();
          },
          activeColor: AppColors.primaryColor,
        ),
      ],
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
            'Essayez de modifier vos critères de recherche ou vos filtres.',
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
                    _userLocation != null
                        ? _formatDistance(_calculateDistanceForCommercant(commercant))
                        : 'Distance N/A',
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
    // Modifié pour utiliser CommercantService qui appelle maintenant Firestore
    setState(() => _isLoading = true);
    try {
      final commercants = await _commercantService.getAllCommercants();
      if (mounted) {
        setState(() {
          _commercants = commercants;
          _filteredCommercants = commercants; // Initialiser avec tous les commerçants
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showErrorSnackBar('Erreur lors du chargement des commerçants: ${e.toString()}');
    }
  }

  Future<void> _loadRecentSearches() async {
    // Méthode non nécessaire pour le moment
  }

  void _filterCommercants(String filter) {
    setState(() {
      _selectedFilter = filter;
      // Les paramètres spécifiques pour chaque filtre rapide seront gérés
      // directement dans _applyFiltersAndSearch en fonction de _selectedFilter.
      _applyFiltersAndSearch();
    });
  }

  void _searchCommercants(String query) {
    // L'appel direct à _applyFiltersAndSearch est déjà géré par le listener du _searchController
    // Donc cette méthode pourrait être simplifiée ou supprimée si _onSearchChanged est suffisant.
    // Pour l'instant, on s'assure que _applyFiltersAndSearch est appelé.
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _applyFiltersAndSearch);
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  // Méthode pour calculer la distance, pourrait être dans un utilitaire
  double _calculateDistanceForCommercant(CommercantModel commercant) {
    if (_userLocation == null) return -1; // Retourne -1 ou lève une exception si pas de loc utilisateur

    const double earthRadius = 6371; // Rayon de la Terre en kilomètres

    final double lat1 = _userLocation!.latitude;
    final double lon1 = _userLocation!.longitude;
    final double lat2 = commercant.localisation.latitude;
    final double lon2 = commercant.localisation.longitude;

    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLon = (lon2 - lon1) * (pi / 180);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // Distance en kilomètres
  }

  String _formatDistance(double distanceKm) {
    if (distanceKm < 0) return "N/A";
    if (distanceKm < 1) {
      return "${(distanceKm * 1000).round()} m";
    }
    return "${distanceKm.toStringAsFixed(1)} km";
  }
}
