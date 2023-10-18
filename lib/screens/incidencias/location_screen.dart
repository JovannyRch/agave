import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/widgets/multiple_location_widget.dart';
import 'package:flutter/material.dart';

class MultipleLocationMap extends StatelessWidget {
  List<Incidencia> incidencias;
  MultipleLocationMap({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MultiLocationMapWidget(
          locations: incidencias
              .map(
                (e) => Location(
                  incidents: e.cantidad ?? 0,
                  id: e.id ?? -1,
                  latitude: e.latitud ?? 0.0,
                  longitude: e.longitud ?? 0.0,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
