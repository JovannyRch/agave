import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/widgets/list_item.dart';
import 'package:agave/screens/estudios/estudio_details_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/formatDate.dart';

class EstudiosScreen extends StatefulWidget {
  const EstudiosScreen({super.key});

  @override
  State<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  EstudiosModel? _model;

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<EstudiosModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudios'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroEstudio(),
            ),
          );
        },
        tooltip: 'Crear nuevo estudio',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _refresh() async {
    Provider.of<EstudiosModel>(context, listen: false).fetchData();
  }

  Widget _body() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: _model?.estudios.isEmpty ?? true
          ? const Center(
              child: Text('No hay estudios disponibles'),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: _list(),
            ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: _model?.estudios.length ?? 0,
      itemBuilder: (context, index) {
        Estudio estudio = _model?.estudios[index] ?? Estudio();

        return ListItem(
            title: estudio.nombre ?? "",
            icon: Icons.folder,
            subtitle: formatDate(estudio.fechaCreacion ?? ""),
            onTap: () {
              _model?.setSelected(estudio);
              Provider.of<EstudiosModel>(context, listen: false)
                  .fetchParcelas();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstudioDetailsScreen(),
                ),
              );
            });
      },
    );
  }
}
