import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  MapboxMapController? _controller;
  Location _location = Location();
  LocationData? _currentLocation;
  List<Symbol> _symbols = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null && _controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentLocation!.latitude!,
                _currentLocation!.longitude!,
              ),
              zoom: 15,
            ),
          ),
        );

        setState(() {
          _addCurrentLocationMarker();
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
    }
  }

  void _addCurrentLocationMarker() async {
    if (_currentLocation != null && _controller != null) {
      await _controller!.addSymbol(
        SymbolOptions(
          geometry: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          iconImage: 'marker-15',
          iconSize: 2.0,
          textField: 'Ma position',
          textOffset: const Offset(0, 1.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapboxMap(
        accessToken: 'VOTRE_TOKEN_MAPBOX', // À remplacer par votre token Mapbox
        onMapCreated: (MapboxMapController controller) {
          _controller = controller;
          _getCurrentLocation();
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(48.8566, 2.3522), // Paris par défaut
          zoom: 12,
        ),
        myLocationEnabled: true,
        myLocationRenderMode: MyLocationRenderMode.NORMAL,
        myLocationTrackingMode: MyLocationTrackingMode.Tracking,
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
