import 'package:agave/api/api.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/kriging/ajuste_screen.dart';
import 'package:agave/utils/formatDate.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/incidencias_tab.dart';
import 'package:agave/widgets/screen_title.dart';
import 'package:agave/screens/incidencias/registro_indicencias_screen.dart';
import 'package:agave/widgets/submit_button.dart';

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
  MuestreosModel? _muestreosModel;

  bool isLoading = false;
  late Size size;

  @override
  void initState() {
    Provider.of<IncidenciasModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _model = Provider.of<IncidenciasModel>(context);
    _muestreosModel = Provider.of<MuestreosModel>(context);
    List<Incidencia> incidencias = _model?.incidencias ?? [];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
      ),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenTitle(
            subtitle: "Plaga",
            title: widget.muestreo.nombrePlaga ?? "",
          ),
          Container(
            height: 250.0,
            /* decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  offset: Offset(0, 5),
                ),
              ],
            ), */
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              children: [
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
                if (widget.muestreo.humedad != null)
                  CardDetail(
                    title: "Humedad",
                    value: widget.muestreo.humedad.toString(),
                    unit: "%",
                    color: Colors.transparent,
                    icon: Icons.water,
                  ),
                if (widget.muestreo.temperatura != null)
                  CardDetail(
                    title: "Temperatura",
                    value: widget.muestreo.temperatura.toString(),
                    unit: "°C",
                    color: Colors.transparent,
                    icon: Icons.thermostat,
                  ),
              ],
            ),
          )
        ],
      ),
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
