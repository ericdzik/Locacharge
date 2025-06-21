// lib/features/home/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pour SystemChannels
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong; // Utilisé pour les objets LatLng de flutter_map
import 'package:locacharge/core/config/app_config.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/localisation_model.dart';
import 'package:locacharge/core/models/horaire_model.dart'; // Import HoraireModel
import 'package:locacharge/features/home/screens/list_view_screen.dart'; // Import ListViewScreen
import 'package:locacharge/features/home/screens/fiche_commercant_screen.dart'; // Import pour la navigation
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
  MapController _mapController = MapController();
  latlong.LatLng _initialCameraPosition = const latlong.LatLng(5.3454, -4.0245); // Abidjan
  bool _myLocationEnabled = false;
  latlong.LatLng? _currentPositionMarker; // Pour stocker la position actuelle de l'utilisateur

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
    // _mapController = MapController(); // Initialisation ici si non fait à la déclaration
    _requestLocationPermission();
    _fetchMockCommercants();
    _searchController.addListener(_onSearchChanged);

    // Appeler les actions initiales après le premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Vérifier si le widget est toujours monté
        _applyFiltersAndSearch(); // Pour afficher les symboles initiaux si nécessaire
        if (_myLocationEnabled) {
          _getCurrentLocationAndCenterMap();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    // _mapController.dispose(); // MapController n'a pas de méthode dispose publique typique comme les contrôleurs de texte.
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
        setState(() {
          _myLocationEnabled = false;
          _currentPositionMarker = null; // Cacher le marqueur si permission refusée
        });
        return;
      }
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      setState(() {
        _myLocationEnabled = true;
      });
      _getCurrentLocationAndCenterMap(); // Obtenir la position et afficher le marqueur
    }
  }

  Future<void> _getCurrentLocationAndCenterMap() async {
    if (!_myLocationEnabled) return;
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialCameraPosition = latlong.LatLng(position.latitude, position.longitude);
        _currentPositionMarker = _initialCameraPosition; // Mettre à jour la position du marqueur
      });
      _mapController.move(_initialCameraPosition, 14.0); // Centrer la carte
    } catch (e) {
      print("Erreur lors de la récupération de la position: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible de récupérer la position: $e')));
      }
    }
  }

  // void _onMapCreated(MapboxMapController controller) { // Remplacé par l'initialisation directe du MapController
  //   _mapController = controller;
  //   _applyFiltersAndSearch();
  //   if (_myLocationEnabled) {
  //      _getCurrentLocationAndCenterMap();
  //   }
  // }

  // _onStyleLoadedCallback n'est plus nécessaire pour flutter_map avec TileLayer simple.

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
      // L'appel à _buildCommercantMarkersList sera fait directement dans le build du MarkerLayer
    });
  }

  List<Marker> _buildCommercantMarkersList(List<CommercantModel> commercants) {
    return commercants.map((commercant) {
      Color markerColor = Colors.grey; // Couleur par défaut pour statut inconnu
      IconData markerIcon = Icons.store_mall_directory; // Icône par défaut

      if (commercant.statutDisponibilite == StatutDisponibilite.disponible) {
        markerColor = Colors.green;
        markerIcon = Icons.store_mall_directory; // Ou une autre icône pour disponible
      } else if (commercant.statutDisponibilite == StatutDisponibilite.epuise) {
        markerColor = Colors.red;
        markerIcon = Icons.error; // Ou une autre icône pour épuisé
      }

      return Marker(
        width: 80.0,
        height: 80.0,
        point: latlong.LatLng(commercant.localisation.latitude, commercant.localisation.longitude),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CommercantDetailScreen(commercant: commercant),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(markerIcon, color: markerColor, size: 30.0),
              // Optionnel: Afficher le nom du commerçant sous l'icône
              // Text(
              //   commercant.nom,
              //   style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
              //   overflow: TextOverflow.ellipsis,
              //   textAlign: TextAlign.center,
              // ),
            ],
          ),
        ),
        // anchorPos: AnchorPos.align(AnchorAlign.top), // Ajuster si le texte est sous l'icône
      );
    }).toList();
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
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initialCameraPosition, // Type latlong.LatLng
          initialZoom: 11.0,
          // onMapEvent: _onMapEvent, // Si besoin de gérer les événements de la carte
          // onTap: _onTap, // Si besoin de gérer les clics sur la carte
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.locacharge',
          ),
          MarkerLayer(
            markers: [
              if (_myLocationEnabled && _currentPositionMarker != null)
                Marker(
                  point: _currentPositionMarker!,
                  width: 80.0,
                  height: 80.0,
                  child: Icon(Icons.my_location, color: Colors.blue.shade700, size: 30.0),
                ),
              ..._buildCommercantMarkersList(_filteredCommercants), // Ajoute les marqueurs des commerçants
            ],
          ),
        ],
      ),
    );
  }
}
