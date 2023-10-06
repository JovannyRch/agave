import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
import 'package:agave/screens/plagas/registro_plaga_screen.dart';
import 'package:flutter/material.dart';

class PlagasScreen extends StatefulWidget {
  const PlagasScreen({super.key});

  @override
  State<PlagasScreen> createState() => _PlagasScreenState();
}

class _PlagasScreenState extends State<PlagasScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Plaga? plaga;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          bool? check = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistroPlaga(),
            ),
          );

          if (check != null && check) {
            _refresh();
          }
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
        child: FutureBuilder<List<Plaga>>(
          future: PlagasProvider.db.getAll(),
          builder: (BuildContext context, AsyncSnapshot<List<Plaga>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Ha ocurrido un error'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay plagas disponibles'));
            } else {
              return SafeArea(
                child: ListView.builder(
                  itemCount: snapshot.data?.length,
                  padding: const EdgeInsets.only(bottom: 80.0),
                  itemBuilder: (context, index) {
                    var plaga = snapshot.data![index];
                    return ListTile(
                      title: Text(plaga.nombre ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              bool? check = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistroPlaga(
                                    plaga: plaga,
                                  ),
                                ),
                              );

                              if (check != null && check) {
                                _refresh();
                              }
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
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {});
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
                  PlagasProvider.db.delete(plaga!.id ?? -1, DB.plagas);
                  Navigator.of(context).pop();
                  _refresh();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
