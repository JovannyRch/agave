import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/screens/incidencias/location_screen.dart';
import 'package:agave/widgets/submit_button.dart';
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
    var list = ListView.builder(
      padding: const EdgeInsets.only(
        bottom: 60.0,
      ),
      itemCount: widget.incidencias.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
              'Ubicación: (${widget.incidencias[index].latitud}, ${widget.incidencias[index].longitud})'),
          subtitle: Text('Incidencias: ${widget.incidencias[index].cantidad}'),
          leading: const Icon(Icons.bug_report),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultipleLocationMap(
                  incidencias: [widget.incidencias[index]],
                ),
              ),
            );
          },
        );
      },
    );
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SubmitButton(
              text: 'Ver mapa completo',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultipleLocationMap(
                      incidencias: widget.incidencias,
                    ),
                  ),
                );
              })
        ],
      ),
      Expanded(
        child: list,
      ),
    ]);
  }
}
