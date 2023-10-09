import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/parcelas/parcelas_screen.dart';
import 'package:agave/screens/parcelas_details_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class EstudioDetailsScreen extends StatefulWidget {
  const EstudioDetailsScreen({super.key});

  @override
  State<EstudioDetailsScreen> createState() => _EstudioDetailsScreenState();
}

class _EstudioDetailsScreenState extends State<EstudioDetailsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Size? size;
  EstudiosModel? _model;

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
              builder: (context) => const ParcelasScreen(),
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
            SizedBox(
              height: size!.height * 0.8,
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
    _model?.fetchParcelas();
  }

  Widget _listaParcelas() {
    List<Parcela> list = _model?.parcelas ?? [];
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: list.isEmpty ? _emptyList() : _list(list),
    );
  }

  Widget _emptyList() {
    return const Center(
      child: Text(
        'No hay parcelas asociadas a este estudio',
      ),
    );
  }

  Widget _list(List<Parcela> list) {
    return ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 100.0),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].nombre ?? ""),
          subtitle: Text('${list[index].tipoAgave}'),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetallesParcela(
                  parcela: list[index],
                  estudio: _model!.estudio ?? Estudio(),
                ),
              ),
            ),
          },
        );
      },
    );
  }
}
