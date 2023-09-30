import 'package:agave/backend/models/Incidencia.dart';
import 'package:agave/backend/widgets/heat_map.dart';
import 'package:agave/backend/widgets/incidencias_tab.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EstudioDetailsScreen extends StatefulWidget {
  const EstudioDetailsScreen({super.key});

  @override
  State<EstudioDetailsScreen> createState() => _EstudioDetailsScreenState();
}

class _EstudioDetailsScreenState extends State<EstudioDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Tenemos 4 tabs
      child: Scaffold(
        appBar: _appBar(),
        body: TabBarView(
          children: [
            _buildGeneralTab(),
            HeatmapScreen(),
            _buildSemivariogramaChart(),
            TabIncidencias(incidencias: [
              Incidencia(
                ubicacion: LatLng(19.432608, -99.133209),
                cantidad: 1,
              ),
              Incidencia(
                ubicacion: LatLng(19.432608, -99.133209),
                cantidad: 1,
              ),
              Incidencia(
                ubicacion: LatLng(19.432608, -99.133209),
                cantidad: 1,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
          'Estudio - [Fecha/Plaga]'), // Puedes personalizar el título aquí
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
      children: const [
        // Información Principal del Estudio (Header)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Icon(Icons.bug_report, size: 40), // ícono de plaga
                Text('Plaga'),
              ],
            ),
            Column(
              children: [
                Icon(Icons.thermostat_outlined,
                    size: 40), // ícono de temperatura
                Text('25.0°C'), // Ejemplo de temperatura
              ],
            ),
            Column(
              children: [
                Icon(Icons.water_damage, size: 40), // ícono de humedad
                Text('25.0%'), // Ejemplo de humedad
              ],
            ),
          ],
        ),
        SizedBox(height: 20),

        // Datos Estadísticos y Modelado (Usa Cards o ListTile para cada dato)
        // ... (Tu código aquí)
      ],
    );
  }

  Widget _buildSemivariogramaChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
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
              FlSpot(0.303, 0.201),
              FlSpot(0.606, 0.403),
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
