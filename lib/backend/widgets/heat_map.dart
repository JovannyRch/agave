import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_heat_map/flutter_heat_map.dart';

class HeatmapScreen extends StatefulWidget {
  @override
  _HeatmapScreenState createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  /* final Set<WeightedLatLng> _heatMapPoints = Set<WeightedLatLng>(); */

  @override
  void initState() {
    super.initState();
    // Supongamos que tienes una lista de puntos con sus respectivas incidencias
    final List<LatLng> points = [
      // Tus puntos van aquí
    ];
    final List<double> intensities = [
      // Las incidencias para cada punto van aquí
    ];

    /* for (int i = 0; i < points.length; i++) {
      _heatMapPoints
          .add(WeightedLatLng(point: points[i], intensity: intensities[i]));
    } */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 400.0,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: const LatLng(19.432608, -99.133209),
            zoom: 15,
          ),
          /* heatmapLayers: [
          HeatmapLayer(
            heatmap: HeatMap(
              points: _heatMapPoints,
              radius: 50,
              intensity: 1,
              threshold: 0.7,
            ),
          ),
        ], */
        ),
      ),
    );
  }
}
