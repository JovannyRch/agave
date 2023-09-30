import 'package:agave/backend/widgets/graficos_estadisticas.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _estadoDelCultivoWidget(),
            const SizedBox(height: 10), // Espaciado entre widgets
            _ultimaPlagaDetectadaWidget(),
            const SizedBox(height: 10),
            _actividadRecienteWidget(),
            const SizedBox(height: 20),
            SizedBox(
              height: 200.0,
              child: _distribucionPlagasWidget(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200.0,
              child: _evolucionCultivoWidget(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200.0,
              child: _incidenciasParcelaWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _estadoDelCultivoWidget() {
    return const Card(
      elevation: 4.0,
      child: ListTile(
        leading:
            Icon(Icons.local_florist, size: 40), // Puedes cambiar este ícono
        title: Text('Estado del Cultivo'),
        subtitle: Text('MADURO (Parcela "San Juan")'),
      ),
    );
  }

  Widget _ultimaPlagaDetectadaWidget() {
    return const Card(
      elevation: 4.0,
      child: ListTile(
        leading: Icon(Icons.bug_report, size: 40), // Puedes cambiar este ícono
        title: Text('Última Plaga Detectada'),
        subtitle: Text('Pulgones - 28 Sept, Parcela "La Luz"'),
      ),
    );
  }

  Widget _actividadRecienteWidget() {
    return const Card(
      elevation: 4.0,
      child: Column(
        children: [
          ListTile(
            title: Text('Actividad Reciente'),
          ),
          Divider(), // Línea separadora
          ListTile(
            leading: Icon(Icons.add_circle_outline),
            title: Text('Nueva Parcela "El Sol"'),
            subtitle: Text('27 Sept'),
          ),
          ListTile(
            leading: Icon(Icons.warning),
            title: Text('Plaga detectada "Trips"'),
            subtitle: Text('26 Sept'),
          ),
          ListTile(
            leading: Icon(Icons.update),
            title: Text('Estado cambiado a "En cosecha"'),
            subtitle: Text('25 Sept'),
          ),
        ],
      ),
    );
  }

  Widget _distribucionPlagasWidget() {
    return PieChart(
      PieChartData(
        sections: [
          // Aquí puedes agregar las diferentes secciones del gráfico de pastel
          // Por ejemplo:
          PieChartSectionData(value: 40, color: Colors.red, title: 'Pulgon'),
          PieChartSectionData(value: 30, color: Colors.blue, title: 'Trips'),
          PieChartSectionData(
              value: 20, color: Colors.green, title: 'Escarabajo'),
          // ... Agrega más plagas según tus datos
        ],
      ),
    );
  }

  Widget _evolucionCultivoWidget() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        minX: 0,
        maxX: 7, // Por ejemplo, 7 días
        minY: 0,
        maxY: 6, // Por ejemplo, 6 estados diferentes del cultivo
        lineBarsData: [
          LineChartBarData(
            spots: [
              // Aquí puedes agregar los datos de la evolución
              // Por ejemplo:
              FlSpot(0, 3),
              FlSpot(1, 1),
              FlSpot(2, 4),
              FlSpot(3, 2),
              // ... Agrega más puntos según tus datos
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
        ],
      ),
    );
  }

  Widget _incidenciasParcelaWidget() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20, // Ajusta según tu máximo de incidencias
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        barGroups: [
          // Aquí puedes agregar los datos de incidencias por parcela
          // Por ejemplo:
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: 8,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.withOpacity(0.3)],
                stops: [0.0, 0.5],
              ),
            ) // Parcela A
          ]),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: 12,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.withOpacity(0.3)],
                  stops: [0.0, 0.5],
                ),
              ) // Parcela B
            ],
          ),
        ],
      ),
    );
  }
}
