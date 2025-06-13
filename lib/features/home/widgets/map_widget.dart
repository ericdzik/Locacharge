import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  Location _location = Location();
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final currentLocation = await _location.getLocation();
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentLatLng =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          center: _currentLatLng ?? LatLng(48.8566, 2.3522),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}",
            additionalOptions: const {
              'accessToken': 'pk.eyJ1IjoibWFwYm94cnMyMSIsImEiOiJjamdkdTU1MTIwMTM2Mnhxa3Y3ZXZ3eGt3In0.PtflK7MObAbmwY1E__H7Fg',
              'id': 'mapbox/streets-v11',
            },
          ),
          if (_currentLatLng != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 40.0,
                  height: 40.0,
                  point: _currentLatLng!,
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
