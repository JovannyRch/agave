import 'package:agave/api/api.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/incidencias/location_screen.dart';
import 'package:agave/screens/kriging/ajuste_screen.dart';
import 'package:agave/utils/formatDate.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/screen_title.dart';
import 'package:agave/screens/incidencias/registro_indicencias_screen.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MuestreoDetailsScreen extends StatefulWidget {
  Muestreo muestreo;
  Parcela parcela;
  Estudio estudio;

  MuestreoDetailsScreen({
    required this.muestreo,
    required this.parcela,
    required this.estudio,
  });

  @override
  State<MuestreoDetailsScreen> createState() => _MuestreoDetailsScreenState();
}

class _MuestreoDetailsScreenState extends State<MuestreoDetailsScreen> {
  IncidenciasModel? _model;
  IncidenciasModel? _incidenciasModel;

  bool isLoading = true;
  late Size size;
  bool isUTM = false;
  bool hasIncidencias = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    Provider.of<IncidenciasModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);
    String tipoCoordenadas = await UserData.obtenerTipoCoordenadas() ?? "UTM";
    if (tipoCoordenadas == "UTM") {
      isUTM = true;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _model = Provider.of<IncidenciasModel>(context);
    _incidenciasModel = Provider.of<IncidenciasModel>(context);

    hasIncidencias = _incidenciasModel?.incidencias.isNotEmpty ?? false;

    return Scaffold(
      appBar: _appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroIncidenciasScreen(
                idMuestreo: widget.muestreo.id ?? -1,
                muestreo: widget.muestreo,
                parcela: widget.parcela,
              ),
            ),
          );
        },
        tooltip: 'Agregar Incidencia',
        child: const Icon(Icons.pin_drop),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SizedBox(
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTitle(
                subtitle: "Plaga",
                title: widget.muestreo.nombrePlaga ?? "",
              ),
              _grid(),
              hasIncidencias ? const Divider() : Container(),
              scrollableActionRowList(),
              const Divider(),
              const SizedBox(
                height: 30.0,
              ),
              const Text(
                "Registros",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              ..._incidenciasList(),
              const SizedBox(height: 80.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowDetails(Widget child1, Widget child2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: child1),
        Expanded(child: child2),
      ],
    );
  }

  List<Widget> _incidenciasList() {
    if (!hasIncidencias) {
      return [
        const SizedBox(
          height: 150.0,
          child: Center(
            child: Text('No hay registros'),
          ),
        ),
      ];
    }

    return _model!.incidencias.map((incidencia) {
      return ListTile(
        leading: const Icon(
          Icons.location_on,
          color: kMainColor,
        ),
        title: Text(
          _getCoordenadas(incidencia),
          style: const TextStyle(
            fontSize: 1.0,
          ),
        ),
        subtitle: Text(
          'Incidencias: ${incidencia.cantidad}',
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MultipleLocationMap(
                incidencias: [incidencia],
              ),
            ),
          );
        },
      );
    }).toList();
  }

  String _getCoordenadas(Incidencia incidencia) {
    if (isUTM) {
      return 'N: ${incidencia.norte}, E: ${incidencia.este}';
    } else {
      return 'Ltd: ${incidencia.latitud}, Lng: ${incidencia.longitud}';
    }
  }

  Widget scrollableActionRowList() {
    //If total number of items is even then remove 1 from total count
    int total = _model?.incidencias.length ?? 0;
    if (total == 0) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RoundedButton(
            text: 'Mapa',
            icon: Icons.map,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultipleLocationMap(
                    incidencias: _model?.incidencias ?? [],
                  ),
                ),
              );
            },
          ),
          RoundedButton(
            text: 'Ajustar',
            onPressed: _iniciarAjuste,
            icon: Icons.settings,
          ),
          RoundedButton(
            icon: Icons.percent,
            text: 'Calculos',
            onPressed: _iniciarAjuste,
          ),
        ],
      ),
    );
  }

  Widget _grid() {
    bool hasHumedad = widget.muestreo.humedad != null;
    bool hasTemperatura = widget.muestreo.temperatura != null;
    return Column(
      children: [
        _rowDetails(
          CardDetail(
            color: Colors.transparent,
            title: "Estudio",
            value: widget.estudio.nombre ?? "",
            icon: Icons.folder,
          ),
          CardDetail(
            title: "Parcela",
            value: widget.parcela.nombre ?? "",
            color: Colors.transparent,
            icon: Icons.nature,
          ),
        ),
        _rowDetails(
          CardDetail(
            title: "Creación",
            value: formatDate(widget.muestreo.fechaCreacion),
            color: Colors.transparent,
            icon: Icons.calendar_today,
          ),
          CardDetail(
            title: "Registros",
            value: _model!.incidencias.length.toString(),
            color: Colors.transparent,
            icon: Icons.list,
          ),
        ),
        (hasHumedad || hasTemperatura)
            ? _rowDetails(
                hasHumedad
                    ? CardDetail(
                        title: "Humedad",
                        value: widget.muestreo.humedad.toString(),
                        unit: "%",
                        color: Colors.transparent,
                        icon: Icons.water,
                      )
                    : Container(),
                hasTemperatura
                    ? CardDetail(
                        title: "Temperatura",
                        value: widget.muestreo.temperatura.toString(),
                        unit: "°C",
                        color: Colors.transparent,
                        icon: Icons.thermostat,
                      )
                    : Container(),
              )
            : Container(),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Muestreo'),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert),
        ),
      ],
    );
  }

  void _iniciarAjuste() async {
    setState(() {
      isLoading = true;
    });
    List<List<double>> points = widget.muestreo.incidencias!
        .map(
          (e) => [
            e.longitud ?? 0.0,
            e.latitud ?? 0.0,
            e.cantidad!.toDouble() ?? 0.0
          ],
        )
        .toList();
    try {
      SemivariogramaResponse? response =
          await Api.getExperimentalSemivariogram(points);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AjusteScreen(
            lags: response?.lags ?? [],
            semivariance: response?.semivariance ?? [],
            points: points,
          ),
        ),
      );

      if (response != null) {
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo obtener el semivariograma'),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el semivariograma'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildSemivariogramaChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1),
        ),
        minX: 0,
        maxX: 7,
        minY: 0,
        maxY: 1.5,
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0.303, 0.201),
              const FlSpot(0.606, 0.403),
              // ... (añade tus datos aquí)
            ],
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.blue.withOpacity(0.3),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
          // Puedes añadir más líneas si es necesario
        ],
      ),
    );
  }
}
