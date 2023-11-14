import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/agaves/registro_agave.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AgavesScreen extends StatefulWidget {
  const AgavesScreen({super.key});

  @override
  State<AgavesScreen> createState() => _AgavesScreenState();
}

class _AgavesScreenState extends State<AgavesScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Agave? agave;
  AgavesModel? _model;

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<AgavesModel>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistroAgave(),
            ),
          );
        },
        tooltip: 'Agregar tipo de planta',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Tipos de plantas'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: _model!.agaves.isEmpty ? _emptyList() : _agavesList(),
      ),
    );
  }

  Future<void> _refresh() async {
    Provider.of<AgavesModel>(context, listen: false).fetchData();
  }

  Widget _emptyList() {
    return const Center(child: Text('No hay tipos de planta disponibles'));
  }

  Widget _agavesList() {
    return ListView.builder(
      itemCount: _model!.agaves.length,
      padding: const EdgeInsets.only(bottom: 80.0),
      itemBuilder: (context, index) {
        var agave = _model!.agaves[index];
        return ListTile(
          title: Text(agave.nombre ?? ""),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistroAgave(
                        agave: agave,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    this.agave = agave;
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar tipo de agave'),
          content: const Text('¿Estás seguro de eliminar este tipo de agave?'),
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
                if (agave != null) {
                  _model?.delete(agave!.id ?? -1);
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
