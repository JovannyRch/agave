import 'package:agave/api/api.dart';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/kriging/ajuste_screen.dart';
import 'package:agave/screens/kriging/kriging_contour_screen.dart';
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

  @override
  void initState() {
    Provider.of<IncidenciasModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            TabIncidencias(incidencias: incidencias),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Acción para compartir
          },
        ),
        // Puedes agregar más iconos para otras acciones aquí
      ],
      bottom: const TabBar(
        tabs: [
          Tab(
              icon: Icon(
            Icons.info,
          )),
          Tab(
            icon: Icon(Icons.table_chart),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ScreenTitle(
          title: widget.muestreo.nombrePlaga ?? "",
          subtitle: "${widget.estudio.nombre} > ${widget.parcela.nombre ?? ""}",
        ),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.muestreo.humedad != null)
                CardDetail(
                  title: "Humedad",
                  value: widget.muestreo.humedad.toString(),
                  unit: "%",
                ),
              if (widget.muestreo.temperatura != null)
                CardDetail(
                  title: "Temperatura",
                  value: widget.muestreo.temperatura.toString(),
                  unit: "°C",
                ),
              CardDetail(
                title: "Registros",
                value: _model!.incidencias.length.toString(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CardDetail(
                title: "Media",
                value: (_muestreosModel!.selectedMuestreo?.media ?? 0.0)
                    .toStringAsFixed(2),
              ),
              CardDetail(
                title: "Varianza",
                value: (_muestreosModel!.selectedMuestreo?.varianza ?? 0.0)
                    .toStringAsFixed(2),
              ),
              CardDetail(
                title: "DE",
                value: (_muestreosModel!.selectedMuestreo?.desviacionEstandar ??
                        0.0)
                    .toStringAsFixed(2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SubmitButton(
              text: "Iniciar Ajuste",
              onPressed: isLoading ? null : _getSemivariograma,
            ),
          ],
        ),
      ],
    );
  }

  void _krigingContour() async {
    setState(() {
      isLoading = true;
    });
    List<double> lats =
        widget.muestreo.incidencias!.map((e) => e.latitud ?? 0.0).toList();
    List<double> lons =
        widget.muestreo.incidencias!.map((e) => e.longitud ?? 0.0).toList();
    List<int> values = widget.muestreo.incidencias!
        .map((e) => (e.cantidad ?? 0.0).toInt())
        .toList();
    try {
      KrigingContourResponse? response =
          await Api.getKrigingContour(lats, lons, values);

      if (response != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KrigingContour(
              krigingContourResponse: response,
            ),
          ),
        );
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

  void _getSemivariograma() async {
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
