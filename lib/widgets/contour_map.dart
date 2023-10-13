import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ContourMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(
          37.7749,
          -122.4194,
        ), // Coordenadas de San Francisco
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        OverlayImageLayer(
          overlayImages: [
            OverlayImage(
              bounds: LatLngBounds(
                const LatLng(37.7749, -122.4194),
                const LatLng(37.7749, -122.4194),
              ),
              opacity: 1,
              imageProvider: const AssetImage('images/krigeado.png'),
            ),
          ],
        ),
      ],
    );
  }
}
