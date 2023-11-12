import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/widgets/multiple_location_widget.dart';
import 'package:flutter/material.dart';

class MultipleLocationMap extends StatelessWidget {
  List<Incidencia> incidencias;
  MultipleLocationMap({required this.incidencias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Ubicaciones'),
      ),
      body: SafeArea(
        child: MultiLocationMapWidget(
          locations: incidencias
              .asMap()
              .keys
              .toList()
              .map(
                (index) => Location(
                  incidents: incidencias[index].cantidad ?? 0,
                  id: index + 1,
                  latitude: incidencias[index].latitud ?? 0.0,
                  longitude: incidencias[index].longitud ?? 0.0,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
