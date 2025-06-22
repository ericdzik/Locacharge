import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:locacharge/core/models/commercant_model.dart';
import 'package:locacharge/core/models/eta_result_model.dart';
import 'package:locacharge/core/services/maps_service.dart';

enum TransportMode { walking, driving, cycling }

class NavigationScreen extends StatefulWidget {
  final CommercantModel commercant;

  const NavigationScreen({
    super.key,
    required this.commercant,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  LatLng? _userLocation;
  TransportMode _selectedTransportMode = TransportMode.driving;
  EtaResult? _etaResult;
  bool _isLoadingEta = false;
  final MapsService _mapsService = MapsService();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer votre position')),
      );
    }
  }

  Future<void> _updateEta() async {
    if (_userLocation == null) return;

    setState(() {
      _isLoadingEta = true;
    });

    try {
      final eta = await _mapsService.getEtaFromOSRM(
        _userLocation!,
        LatLng(widget.commercant.localisation.latitude,
            widget.commercant.localisation.longitude),
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

  Future<void> _openInMaps() async {
    final String address = widget.commercant.localisation.adresse ?? '';
    final String encodedAddress = Uri.encodeComponent(address);

    // URLs pour différentes applications
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    final String appleMapsUrl = 'https://maps.apple.com/?q=$encodedAddress';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl),
            mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(Uri.parse(appleMapsUrl),
            mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Aucune application de cartographie disponible');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir les cartes: $e')),
        );
      }
    }
  }

  Widget _buildTransportModeSelector() {
    return SegmentedButton<TransportMode>(
      segments: const [
        ButtonSegment(
          value: TransportMode.walking,
          label: Text('À pied'),
          icon: Icon(Icons.directions_walk),
        ),
        ButtonSegment(
          value: TransportMode.driving,
          label: Text('En voiture'),
          icon: Icon(Icons.directions_car),
        ),
        ButtonSegment(
          value: TransportMode.cycling,
          label: Text('À vélo'),
          icon: Icon(Icons.directions_bike),
        ),
      ],
      selected: {_selectedTransportMode},
      onSelectionChanged: (Set<TransportMode> newSelection) {
        setState(() {
          _selectedTransportMode = newSelection.first;
        });
        _updateEta();
      },
    );
  }

  Widget _buildDetailedRoute() {
    if (_userLocation == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Position non disponible'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Itinéraire recommandé',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildTransportModeSelector(),
            const SizedBox(height: 16),
            if (_isLoadingEta)
              const Center(child: CircularProgressIndicator())
            else if (_etaResult != null)
              _buildEtaDetails()
            else
              const Text('Calcul en cours...'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openInMaps,
                icon: const Icon(Icons.map),
                label: const Text('Ouvrir dans Maps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtaDetails() {
    if (_etaResult == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Icon(Icons.access_time,
                    color: Theme.of(context).primaryColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  _etaResult!.durationFormatted,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Text('Durée', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            Column(
              children: [
                Icon(Icons.straighten,
                    color: Theme.of(context).primaryColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  _etaResult!.distanceFormatted,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Text('Distance', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Temps estimé basé sur les conditions de trafic actuelles',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Navigation vers ${widget.commercant.nom}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du commerçant
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.commercant.nom,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.commercant.localisation.adresse ??
                                'Adresse non disponible',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (widget.commercant.telephone != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone,
                              color: Theme.of(context).primaryColor),
                          const SizedBox(width: 8),
                          Text(widget.commercant.telephone!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Section itinéraire détaillé
            _buildDetailedRoute(),
          ],
        ),
      ),
    );
  }
}
