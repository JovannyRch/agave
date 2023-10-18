import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapLocationWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  MapLocationWidget({required this.latitude, required this.longitude});

  @override
  _MapLocationWidgetState createState() => _MapLocationWidgetState();
}

class _MapLocationWidgetState extends State<MapLocationWidget> {
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.latitude, widget.longitude),
        zoom: 15,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller = controller;
      },
      markers: {
        Marker(
          markerId: MarkerId('location'),
          position: LatLng(widget.latitude, widget.longitude),
        ),
      },
    );
  }
}
