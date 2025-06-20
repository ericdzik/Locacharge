// lib/features/home/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour SystemChannels
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:locacharge/core/config/app_config.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/horaire_model.dart'; // Import HoraireModel
import 'package:locacharge/features/home/screens/list_view_screen.dart'; // Import ListViewScreen
// Pour l'internationalisation (exemple)
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';


// (ColorToString extension from previous step should be here or in a utils file)
extension ColorToString on Color {
  String toHexStringRGB() {
    return '#${red.toRadixString(16).padLeft(2, '0')}'
           '${green.toRadixString(16).padLeft(2, '0')}'
           '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapboxMapController? _mapController;
  LatLng _initialCameraPosition = const LatLng(5.3454, -4.0245); // Abidjan
  bool _myLocationEnabled = false;

  List<CommercantModel> _allCommercants = []; // Tous les commerçants chargés
  List<CommercantModel> _filteredCommercants = []; // Commerçants après recherche et filtres

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // États des filtres
  StatutDisponibilite? _selectedDisponibilite;
  bool? _selectedOuverture; // true pour ouvert, false pour fermé, null pour pas de filtre

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _fetchMockCommercants();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose(); // Dispose map controller
    super.dispose();
  }

  void _fetchMockCommercants() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _allCommercants = [
          CommercantModel(
            id: '1',
            nom: 'Boutique Chez Ali',
            localisation: LocalisationModel(latitude: 5.3550, longitude: -4.0200, adresse: "Treichville Centre"),
            horaires: [HoraireModel(jour: "Lundi", ouverture: "08:00", fermeture: "19:00")], // Exemple
            statutDisponibilite: StatutDisponibilite.disponible,
            telephone: "0102030405"
          ),
          CommercantModel(
            id: '2',
            nom: 'Station Service Shell Cocody',
            localisation: LocalisationModel(latitude: 5.3600, longitude: -3.9900, adresse: "Cocody Danga"),
            horaires: [HoraireModel(jour: "Mardi", ouverture: "00:00", fermeture: "23:59", estOuvert24h: true)], // Ouvert 24h
            statutDisponibilite: StatutDisponibilite.epuise,
            telephone: "0506070809"
          ),
          CommercantModel(
            id: '3',
            nom: 'Le Kiosque Orange Money Marcory',
            localisation: LocalisationModel(latitude: 5.3480, longitude: -4.0280, adresse: "Marcory Remblais"),
            horaires: [HoraireModel(jour: "Mercredi", ouverture: "10:00", fermeture: "17:00")], // Supposons fermé actuellement pour test
            statutDisponibilite: StatutDisponibilite.disponible,
            telephone: "0708090001"
          ),
           CommercantModel(
            id: '4',
            nom: 'Pharmacie de la Savane',
            localisation: LocalisationModel(latitude: 5.3510, longitude: -4.0150, adresse: "Treichville Savane"),
            horaires: [HoraireModel(jour: "Jeudi", ouverture: "08:00", fermeture: "22:00")],
            statutDisponibilite: StatutDisponibilite.disponible,
            telephone: "0700000001"
          ),
        ];
        _applyFiltersAndSearch();
      });
    });
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée.')),
          );
        }
        setState(() { _myLocationEnabled = false; });
        return;
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      setState(() { _myLocationEnabled = true; });
      _getCurrentLocationAndCenterMap();
    }
  }

  Future<void> _getCurrentLocationAndCenterMap() async {
    if (!_myLocationEnabled || _mapController == null) return;
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _initialCameraPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_initialCameraPosition, 14.0));
    } catch (e) {
      print("Erreur lors de la récupération de la position: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de récupérer la position: $e')));
      }
    }
  }

  void _onMapCreated(MapboxMapController controller) {
    _mapController = controller;
    _applyFiltersAndSearch();
    if (_myLocationEnabled) {
       _getCurrentLocationAndCenterMap();
    }
  }

  void _onStyleLoadedCallback() {
    print("Style de carte chargé.");
    _applyFiltersAndSearch();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _applyFiltersAndSearch();
    });
  }

  void _applyFiltersAndSearch() {
    if (!mounted) return;
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCommercants = _allCommercants.where((commercant) {
        final bool matchesSearch = query.isEmpty ||
            commercant.nom.toLowerCase().contains(query) ||
            (commercant.localisation.adresse?.toLowerCase().contains(query) ?? false);

        final bool matchesDisponibilite = _selectedDisponibilite == null ||
            commercant.statutDisponibilite == _selectedDisponibilite;

        final bool matchesOuverture = _selectedOuverture == null ||
             (_selectedOuverture == true ? commercant.estOuvertMaintenant : !commercant.estOuvertMaintenant);

        return matchesSearch && matchesDisponibilite && matchesOuverture;
      }).toList();
      _addOrUpdateCommercantSymbols();
    });
  }

  void _addOrUpdateCommercantSymbols() {
    if (_mapController == null) return;

    _mapController?.clearSymbols();

    for (var commercant in _filteredCommercants) {
      Color symbolColor = Colors.grey;
      if (commercant.statutDisponibilite == StatutDisponibilite.disponible) {
        symbolColor = Colors.green;
      } else if (commercant.statutDisponibilite == StatutDisponibilite.epuise) {
        symbolColor = Colors.red;
      }

      _mapController?.addSymbol(
        SymbolOptions(
          geometry: LatLng(commercant.localisation.latitude, commercant.localisation.longitude),
          iconColor: symbolColor.toHexStringRGB(),
          iconImage: "circle-15",
          iconSize: 1.5,
          textField: commercant.nom,
          textOffset: const Offset(0, 1.5),
        ),
        // {'commercantId': commercant.id}
      );
    }
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(_selectedDisponibilite == StatutDisponibilite.disponible
                            ? "Disponible ✅"
                            : _selectedDisponibilite == StatutDisponibilite.epuise
                              ? "Épuisé ❌"
                              : "Disponibilité"),
                selected: _selectedDisponibilite != null,
                onSelected: (bool selected) {
                  setState(() {
                    if (_selectedDisponibilite == null) {
                      _selectedDisponibilite = StatutDisponibilite.disponible;
                    } else if (_selectedDisponibilite == StatutDisponibilite.disponible) {
                      _selectedDisponibilite = StatutDisponibilite.epuise;
                    } else {
                      _selectedDisponibilite = null;
                    }
                    _applyFiltersAndSearch();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FilterChip(
                label: Text(_selectedOuverture == true
                            ? "Ouvert 🕒"
                            : _selectedOuverture == false
                              ? "Fermé 🔒"
                              : "Statut"),
                selected: _selectedOuverture != null,
                onSelected: (bool selected) {
                   setState(() {
                    if (_selectedOuverture == null) {
                      _selectedOuverture = true;
                    } else if (_selectedOuverture == true) {
                      _selectedOuverture = false;
                    } else {
                      _selectedOuverture = null;
                    }
                    _applyFiltersAndSearch();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ActionChip(
                label: const Text("Distance 📍"),
                onPressed: () {
                  if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filtre de distance à implémenter.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context)!;

    if (AppConfig.mapboxAccessToken == 'YOUR_MAPBOX_ACCESS_TOKEN_HERE' || AppConfig.mapboxAccessToken.isEmpty) {
       return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Erreur: Clé d'accès Mapbox non configurée.\n"
              "Veuillez configurer `mapboxAccessToken` dans `lib/core/config/app_config.dart`.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("LocaCharge"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocationAndCenterMap,
            tooltip: "Centrer sur ma position",
          ),
          // IconButton pour la vue liste supprimé d'ici
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Rechercher une boutique, un quartier...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
                _buildFilterChips(),
              ],
            ),
          ),
        ),
      ),
      body: MapboxMap(
        accessToken: AppConfig.mapboxAccessToken,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        initialCameraPosition: CameraPosition(
          target: _initialCameraPosition,
          zoom: 11.0,
        ),
        myLocationEnabled: _myLocationEnabled,
        myLocationTrackingMode: _myLocationEnabled ? MyLocationTrackingMode.Tracking : MyLocationTrackingMode.None,
        // styleString: MapboxStyles.MAPBOX_STREETS,
      ),
    );
  }
}
