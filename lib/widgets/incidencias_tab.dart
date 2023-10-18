import 'package:agave/backend/models/Incidencia.dart';
import 'package:flutter/material.dart';

class TabIncidencias extends StatefulWidget {
  final List<Incidencia> incidencias;

  const TabIncidencias({super.key, required this.incidencias});

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
              'Ubicación: (${widget.incidencias[index].latitud}, ${widget.incidencias[index].longitud})'),
          subtitle: Text('Incidencias: ${widget.incidencias[index].cantidad}'),
          leading: const Icon(Icons.bug_report),
          onTap: () {},
          // Puedes agregar más interacciones o detalles si lo deseas
        );
      },
    );
  }
}
