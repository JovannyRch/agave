import 'package:agave/backend/models/Incidencia.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/widgets/card_detail.dart';
import 'package:agave/backend/widgets/heat_map.dart';
import 'package:agave/backend/widgets/incidencias_tab.dart';
import 'package:agave/screens/incidencias/registro_indicencias_screen.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MuestreoDetailsScreen extends StatefulWidget {
  Muestreo muestreo;

  MuestreoDetailsScreen({required this.muestreo});

  @override
  State<MuestreoDetailsScreen> createState() => _MuestreoDetailsScreenState();
}

class _MuestreoDetailsScreenState extends State<MuestreoDetailsScreen> {
  IncidenciasModel? _model;

  @override
  void initState() {
    Provider.of<IncidenciasModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<IncidenciasModel>(context);
    List<Incidencia> incidencias = _model?.incidencias ?? [];
    return DefaultTabController(
      length: 4,
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
            const HeatmapScreen(),
            _buildSemivariogramaChart(),
            TabIncidencias(incidencias: incidencias),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        widget.muestreo.nombrePlaga ?? "",
      ), // Puedes personalizar el título aquí
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
            icon: Icon(Icons.map),
          ),
          Tab(
            icon: Icon(Icons.line_axis),
          ),
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
                title: "Incidencias",
                value: _model!.incidencias.length.toString(),
              ),
            ],
          ),
        )
      ],
    );
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
