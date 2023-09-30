import 'package:agave/backend/models/Incidencia.dart';
import 'package:flutter/material.dart';

class TabIncidencias extends StatefulWidget {
  final List<Incidencia> incidencias;

  TabIncidencias({required this.incidencias});

  @override
  _TabIncidenciasState createState() => _TabIncidenciasState();
}

class _TabIncidenciasState extends State<TabIncidencias> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.incidencias.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
              'Ubicación: (${widget.incidencias[index].ubicacion.latitude}, ${widget.incidencias[index].ubicacion.longitude})'),
          subtitle: Text('Incidencias: ${widget.incidencias[index].cantidad}'),
          leading: Icon(Icons.bug_report),
          // Puedes agregar más interacciones o detalles si lo deseas
        );
      },
    );
  }
}
