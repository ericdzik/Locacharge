// lib/features/home/screens/fiche_commercant_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/horaire_model.dart';
import 'package:locacharge/core/models/eta_result_model.dart';
import 'package:locacharge/core/models/produit_model.dart';
import 'package:locacharge/core/services/maps_service.dart';
import 'package:locacharge/core/services/history_service.dart';
import 'package:locacharge/core/services/commercant_service.dart';
import 'package:locacharge/core/services/analytics_service.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:url_launcher/url_launcher.dart';

enum TransportMode { walking, driving, cycling }

class FicheCommercantScreen extends StatefulWidget {
  final String commercantId;

  const FicheCommercantScreen({
    super.key,
    required this.commercantId,
  });

  @override
  State<FicheCommercantScreen> createState() => _FicheCommercantScreenState();
}

class _FicheCommercantScreenState extends State<FicheCommercantScreen> {
  final CommercantService _commercantService = CommercantService();
  final HistoryService _historyService = HistoryService();
  final AnalyticsService _analyticsService = AnalyticsService();
  final MapsService _mapsService = MapsService();

  CommercantModel? _commercant;
  bool _isLoading = true;
  bool _isFavorite = false;
  TransportMode _selectedTransportMode = TransportMode.driving;
  final List<TransportMode> _transportModes = [
    TransportMode.driving,
    TransportMode.cycling,
    TransportMode.walking,
  ];

  LatLng? _userLocation;
  EtaResult? _etaResult;
  bool _isLoadingEta = false;

  @override
  void initState() {
    super.initState();
    _loadCommercant();
    _getUserLocation();
  }

  Future<void> _loadCommercant() async {
    try {
      final commercant =
          await _commercantService.getCommercantById(widget.commercantId);
      setState(() {
        _commercant = commercant;
        _isLoading = false;
      });

      // Ajouter aux visites récentes
      if (commercant != null) {
        _historyService.addRecentVisit(commercant.nom);
        _analyticsService.recordCommercantView(commercant.id, null);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Erreur lors du chargement du commerçant');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
      _updateEta();
    } catch (e) {
      print('Erreur de géolocalisation: $e');
      _showErrorSnackBar('Impossible de récupérer votre position');
    }
  }

  Future<void> _updateEta() async {
    if (_userLocation == null || _commercant == null) return;
    setState(() {
      _isLoadingEta = true;
    });
    try {
      final eta = await _mapsService.getEtaFromOSRM(
        _userLocation!,
        LatLng(_commercant!.localisation.latitude,
            _commercant!.localisation.longitude),
        _getTransportModeString(_selectedTransportMode),
      );
      setState(() {
        _etaResult = eta;
        _isLoadingEta = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingEta = false;
      });
      print('Erreur lors du calcul ETA: $e');
    }
  }

  String _getTransportModeString(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'foot-walking';
      case TransportMode.driving:
        return 'driving-car';
      case TransportMode.cycling:
        return 'cycling-regular';
    }
    return 'driving-car';
  }

  void _toggleFavorite() {
    if (_commercant != null) {
      setState(() {
        _isFavorite = !_isFavorite;
      });

      if (_isFavorite) {
        _historyService.addFavorite(_commercant!.id);
      } else {
        _historyService.removeFavorite(_commercant!.id);
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

  Future<void> _launchMaps() async {
    if (_commercant == null) return;

    final lat = _commercant!.localisation.latitude;
    final lng = _commercant!.localisation.longitude;
    final address = _commercant!.localisation.adresse ?? '';

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$address';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Impossible d\'ouvrir les cartes');
    }
  }

  Future<void> _callCommercant() async {
    if (_commercant?.telephone == null) {
      _showErrorSnackBar('Numéro de téléphone non disponible');
      return;
    }

    final url = 'tel:${_commercant!.telephone}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      _showErrorSnackBar('Impossible d\'appeler ce numéro');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
      );
    }

    if (_commercant == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Commerçant non trouvé',
            style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image de fond
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    // Image de fond ou placeholder
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.store,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    // Informations du commerçant
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _commercant!.nom,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withOpacity(0.8),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _commercant!.localisation.adresse ??
                                      'Adresse non disponible',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut et note
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _commercant!.estOuvertMaintenant
                              ? AppColors.successColor.withOpacity(0.1)
                              : AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _commercant!.estOuvertMaintenant
                                  ? Icons.circle
                                  : Icons.circle_outlined,
                              size: 12,
                              color: _commercant!.estOuvertMaintenant
                                  ? AppColors.successColor
                                  : AppColors.errorColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _commercant!.estOuvertMaintenant
                                  ? 'Ouvert'
                                  : 'Fermé',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _commercant!.estOuvertMaintenant
                                    ? AppColors.successColor
                                    : AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (_commercant!.note != null) ...[
                        Icon(Icons.star,
                            color: AppColors.accentColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_commercant!.note!.toStringAsFixed(1)} (${_commercant!.nombreEvaluations})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Services proposés
                  const Text(
                    'Services proposés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _commercant!.services.map((service) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
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

                  const SizedBox(height: 24),

                  // Horaires
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Horaires d\'ouverture',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._commercant!.horaires.map((horaire) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  horaire.jour,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${horaire.ouverture} - ${horaire.fermeture}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigation et ETA
                  ModernCardWithGradient(
                    gradient: AppColors.secondaryGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Navigation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Mode de transport
                        Row(
                          children: [
                            const Text(
                              'Mode de transport:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<TransportMode>(
                                value: _selectedTransportMode,
                                dropdownColor: AppColors.secondaryColor,
                                style: const TextStyle(color: Colors.white),
                                underline: Container(),
                                items: _transportModes.map((mode) {
                                  return DropdownMenuItem(
                                    value: mode,
                                    child: Text(_getTransportModeLabel(mode)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedTransportMode = value;
                                    });
                                    _updateEta();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // ETA
                        if (_isLoadingEta)
                          const Row(
                            children: [
                              SizedBox(width: 8),
                              CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                              SizedBox(width: 12),
                              Text('Calcul en cours...',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )
                        else if (_etaResult != null)
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'ETA: ${_etaResult!.durationFormatted}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Distance: ${_etaResult!.distanceFormatted}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        else
                          const Text('ETA non disponible',
                              style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: ModernPrimaryButton(
                          text: 'Itinéraire',
                          onPressed: () {
                            if (_commercant != null) {
                              context.go('/home/navigation/${_commercant!.id}');
                            }
                          },
                          icon: Icons.directions,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernSecondaryButton(
                          text: 'Ouvrir dans Maps',
                          onPressed: _launchMaps,
                          icon: Icons.map,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ModernSecondaryButton(
                          text: 'Appeler',
                          onPressed: _callCommercant,
                          icon: Icons.phone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Produits disponibles
                  if (_commercant!.produits.isNotEmpty) ...[
                    const Text(
                      'Produits disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._commercant!.produits.map((produit) {
                      return ModernCard(
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getProductIcon(produit.type),
                                color: AppColors.accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit.nom,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${produit.prix} FCFA',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: produit.estDisponible
                                    ? AppColors.successColor.withOpacity(0.1)
                                    : AppColors.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                produit.estDisponible
                                    ? 'Disponible'
                                    : 'Indisponible',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: produit.estDisponible
                                      ? AppColors.successColor
                                      : AppColors.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],

                  const SizedBox(height: 100), // Espace pour le FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ModernFloatingActionButton(
        icon: Icons.navigation,
        onPressed: _launchMaps,
      ),
    );
  }

  String _getTransportModeLabel(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'À pied';
      case TransportMode.driving:
        return 'En voiture';
      case TransportMode.cycling:
        return 'À vélo';
    }
    return 'En voiture';
  }

  IconData _getProductIcon(TypeProduit type) {
    switch (type) {
      case TypeProduit.rechargeTelephonique:
        return Icons.phone_android;
      case TypeProduit.forfaitInternet:
        return Icons.wifi;
      case TypeProduit.mobileMoney:
        return Icons.account_balance_wallet;
      case TypeProduit.cartesPrepayees:
        return Icons.credit_card;
      default:
        return Icons.shopping_bag;
    }
  }
}
