import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
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
  bool isLoading = true;
  bool isUTM = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    String tipoCoordenadas = await UserData.obtenerTipoCoordenadas() ?? "UTM";
    if (tipoCoordenadas == "UTM") {
      isUTM = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  String _getCoordenadas(Incidencia incidencia) {
    if (isUTM) {
      return 'N: ${incidencia.norte}, E: ${incidencia.este}';
    } else {
      return 'Ltd: ${incidencia.latitud}, Lng: ${incidencia.longitud}';
    }
  }

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
            _getCoordenadas(widget.incidencias[index]),
          ),
          subtitle: Text('Incidencias: ${widget.incidencias[index].cantidad}'),
          leading: const Icon(
            Icons.search,
            color: kMainColor,
          ),
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
