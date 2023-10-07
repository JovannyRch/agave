import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/plagas/registro_plaga_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlagasScreen extends StatefulWidget {
  const PlagasScreen({super.key});

  @override
  State<PlagasScreen> createState() => _PlagasScreenState();
}

class _PlagasScreenState extends State<PlagasScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Plaga? plaga;
  PlagasModel? model;

  @override
  Widget build(BuildContext context) {
    model = Provider.of<PlagasModel>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistroPlaga(),
            ),
          );
        },
        tooltip: 'Agregar Plaga',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Plagas'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: SafeArea(
          child: model!.plagas.isEmpty ? _emptyList() : _list(),
        ),
      ),
    );
  }

  Widget _emptyList() {
    return const Center(child: Text('No hay plagas disponibles'));
  }

  Widget _list() {
    return ListView.builder(
      itemCount: model?.plagas.length ?? 0,
      padding: const EdgeInsets.only(bottom: 100.0),
      itemBuilder: (context, index) {
        var plaga = model?.plagas[index];

        return ListTile(
          title: Text(plaga!.nombre ?? ""),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistroPlaga(
                        plaga: plaga,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    this.plaga = plaga;
                  });
                  _showDeleteConfirmationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    Provider.of<PlagasModel>(context, listen: false).fetchData();
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar plaga'),
          content: const Text('¿Estás seguro de eliminar esta plaga?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                if (plaga != null) {
                  model?.delete(plaga!.id ?? -1);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
