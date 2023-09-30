import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  HomeScreen({super.key});

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
            /*  _accesoDirectoWidget(context), */
            _busquedaRapidaWidget(),
            _estadoDelCultivoWidget(),
            const SizedBox(height: 10), // Espaciado entre widgets
            _ultimaPlagaDetectadaWidget(),
            const SizedBox(height: 10),
            _actividadRecienteWidget(),
            const SizedBox(height: 20),
            _distribucionPlagasWidget(),
            const SizedBox(height: 20),
            _evolucionCultivoWidget(),
            const SizedBox(height: 20),
            _incidenciasParcelaWidget(),
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

  Widget _chartCard(String title, Widget content) {
    return Card(
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(title),
            ),
            const Divider(), // Línea separadora
            SizedBox(
              height: 200.0,
              child: content,
            )
          ],
        ),
      ),
    );
  }

  Widget _distribucionPlagasWidget() {
    Widget content = PieChart(
      PieChartData(
        sections: [
          // Aquí puedes agregar las diferentes secciones del gráfico de pastel
          // Por ejemplo:
          PieChartSectionData(
              value: 40, color: Colors.red, title: 'Pulgon (40)'),
          PieChartSectionData(
              value: 30, color: Colors.blue, title: 'Trips (30)'),
          PieChartSectionData(
              value: 20, color: Colors.green, title: 'Escarabajo (20)'),
        ],
      ),
    );
    return _chartCard('Distribución de plagas', content);
  }

  Widget _evolucionCultivoWidget() {
    Widget content = LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
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
              const FlSpot(0, 3),
              const FlSpot(1, 1),
              const FlSpot(2, 4),
              const FlSpot(3, 2),
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
    return _chartCard("Evolución de cultivos", content);
  }

  Widget _incidenciasParcelaWidget() {
    Widget content = BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20, // Ajusta según tu máximo de incidencias
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: 8,
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blue.withOpacity(0.3)],
                stops: const [0.0, 0.5],
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
                  stops: const [0.0, 0.5],
                ),
              ) // Parcela B
            ],
          ),
        ],
      ),
    );
    return _chartCard("Incidencias por parcela", content);
  }

  Widget _busquedaRapidaWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: "Búsqueda rápida",
          hintText: "Buscar parcela, plaga, etc.",
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
        onChanged: (value) {
          // Aquí puedes implementar la lógica de búsqueda
          // Por ejemplo, filtrar la lista de parcelas basado en la consulta de búsqueda
        },
      ),
    );
  }

  Widget _accesoDirectoWidget(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Para evitar el scroll dentro del GridView
      crossAxisCount: 2, // Número de columnas
      children: [
        _crearBotonAccesoDirecto(
          context,
          Icons.add,
          "Nueva Parcela",
          _accionNuevaParcela,
        ),
        _crearBotonAccesoDirecto(
          context,
          Icons.bug_report,
          "Reporte de Plagas",
          _accionReportePlagas,
        ),
      ],
    );
  }

  Widget _crearBotonAccesoDirecto(
      BuildContext context, IconData icono, String texto, Function accion) {
    return InkWell(
      onTap: () {
        accion();
      },
      child: Column(
        children: [
          Icon(icono, size: 50.0),
          const SizedBox(height: 10.0),
          Text(texto, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  void _accionNuevaParcela() {
    // Navegación o acción para "Nueva Parcela"
  }

  void _accionReportePlagas() {
    // Navegación o acción para "Reporte de Plagas"
  }
}
