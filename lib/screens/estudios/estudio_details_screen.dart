import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/parcelas/parcels_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class EstudioDetailsScreen extends StatefulWidget {
  EstudioDetailsScreen({super.key});

  @override
  State<EstudioDetailsScreen> createState() => _EstudioDetailsScreenState();
}

class _EstudioDetailsScreenState extends State<EstudioDetailsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Size? size;
  EstudiosModel? _model;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<EstudiosModel>(context);

    size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Estudio'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          _deleteButton(),
          _editButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParcelasScreen(),
            ),
          );
        },
        tooltip: 'Agregar Parcela',
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre: ${_model?.estudio!.nombre ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha de Creación: ${formatDate(_model?.estudio?.fechaCreacion)}',
            ),
            _renderObservaciones(),
            // Aquí puede ir la lista de Parcelas Asociadas
            SizedBox(
              height: size!.height * 0.7,
              child: _listaParcelas(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        _showDeleteConfirmationDialog(context);
      },
    );
  }

  Widget _renderObservaciones() {
    if (_model?.estudio!.observaciones == null ||
        _model?.estudio!.observaciones == "") {
      return Container();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        const Text(
          "Observaciones",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Text(_model?.estudio!.observaciones ?? ""),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Estudio"),
          content: const Text("¿Estás seguro de eliminar este estudio?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                _model?.delete(_model?.estudio!.id ?? -1);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  Widget _editButton() {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistroEstudio(
              estudio: _model?.estudio,
            ),
          ),
        );
      },
    );
  }

  Widget _detalleParcela() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          _model?.estudio!.nombre ?? "",
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        _renderObservaciones(),
      ],
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _listaParcelas() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder<List<Parcela>>(
        future: ParcelasProvider.db.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<Parcela>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Ha ocurrido un error al obtener las parcelas asociadas',
              ),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay parcelas asociadas'),
            );
          } else {
            Widget list = ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: const Text("Estudio"),
                  subtitle: Text(
                    formatDate(snapshot.data?[index].fechaCreacion),
                  ),
                  onTap: () {
                    /* Estudio estudio = snapshot.data?[index] ?? Estudio();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstudioDetailsScreen(
                          estudio: estudio,
                        ),
                      ),
                    ); */
                  },
                );
              },
            );

            return Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Parcelas Asociadas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                list,
              ],
            );
          }
        },
      ),
    );
  }
}
