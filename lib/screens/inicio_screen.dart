import 'package:agave/backend/models/actividad.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/incidencia_plaga.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/models/ultima_plaga.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/muestreos_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/muestreos/muestreo_details_screen.dart';
import 'package:agave/utils/formatDate.dart';
import 'package:agave/utils/randomColor.dart';
import 'package:agave/utils/truncateText.dart';
import 'package:agave/widgets/actividad_item.dart';
import 'package:agave/widgets/home_list_item.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  ReportesModel? _reportesModel;

  bool isLoading = true;
  List<Actividad> actividades = [];
  UltimaPlaga? ultimaPlaga;
  MuestreosModel? _muestreosModel;

  @override
  void initState() {
    _loadData();

    super.initState();
  }

  void _loadData() async {
    setState(() {
      isLoading = true;
    });
    actividades = await UserData.obtenerActividadReciente();
    ultimaPlaga = await UserData.obtenerUltimaPlaga();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _refresh() async {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    _muestreosModel = Provider.of<MuestreosModel>(context);
    _reportesModel = Provider.of<ReportesModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: kMainColor,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          /*  _accesoDirectoWidget(context), */
          _busquedaRapidaWidget(),
          /*    _estadoDelCultivoWidget(),
          const SizedBox(height: 10), // Espaciado entre widgets */
          if (ultimaPlaga != null) _ultimaPlagaDetectadaWidget(),
          if (ultimaPlaga != null) const SizedBox(height: 20),
          _actividadRecienteWidget(),
          const SizedBox(height: 20),
          _distribucionPlagasWidget(),
          const SizedBox(height: 20),
          /*  _evolucionCultivoWidget(),
          const SizedBox(height: 20),
          _incidenciasParcelaWidget(), */
        ],
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
    String nombre = ultimaPlaga!.nombre;
    String fecha = formatDate(ultimaPlaga!.fecha);
    String parcela = ultimaPlaga!.parcela;
    return Card(
      elevation: 4.0,
      child: HomeListItem(
        subtitle: "$fecha - $parcela",
        title: "$nombre",
        description: "Última plaga detectada",
        actionText: "Continuar muestreo",
        icon: const Icon(
          Icons.search,
          color: kMainColor,
          size: 50.0,
        ),
        onTap: () async {
          Muestreo? muestreo = await MuestreosProvider.db
              .getOneWithPlaga(ultimaPlaga!.idMuestreo ?? -1);
          if (muestreo != null) {
            goToMuestreo(muestreo);
          }
        },
      ),
    );
  }

  Widget _actividadRecienteWidget() {
    if (actividades.isEmpty) return Container();

    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          const ListTile(
            title: Text('Actividad Reciente'),
          ),
          const Divider(),
          Column(
            children: [
              for (var actividad in actividades)
                ActividadItem(actividad: actividad),
            ],
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
    List<IncidenciaPlaga> list = _reportesModel?.incidenciasPlaga ?? [];

    if (list.isEmpty) {
      return Container();
    }

    Widget content = PieChart(
      PieChartData(
        sections: list
            .map(
              (e) => PieChartSectionData(
                color: getRandomColor(),
                value: e.cantidad.toDouble(),
                title:
                    "${truncateText(e.plaga, 12)} (${e.cantidad.toDouble()})",
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
            .toList(),
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

  void goToMuestreo(Muestreo muestreo) async {
    Parcela? parcela =
        await ParcelasProvider.db.getById(muestreo.idParcela ?? -1);

    Estudio? estudio =
        await EstudiosProvider.db.getById(muestreo.idEstudio ?? -1);

    _muestreosModel!.setSelected(muestreo);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuestreoDetailsScreen(
          parcela: parcela!,
          estudio: estudio,
          muestreo: muestreo,
        ),
      ),
    );
  }
}
