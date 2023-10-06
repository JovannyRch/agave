import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/agave_provider.dart';
import 'package:agave/screens/agaves/registro_agave.dart';
import 'package:agave/screens/plagas/registro_plaga_screen.dart';
import 'package:flutter/material.dart';

class AgavesScreen extends StatefulWidget {
  const AgavesScreen({super.key});

  @override
  State<AgavesScreen> createState() => _AgavesScreenState();
}

class _AgavesScreenState extends State<AgavesScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Agave? agave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          bool? check = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroAgave(),
            ),
          );

          if (check != null && check) {
            _refresh();
          }
        },
        tooltip: 'Agregar tipo de Agave',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Tipos de Agave'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: FutureBuilder<List<Agave>>(
          future: AgaveProvider.db.getAll(),
          builder: (BuildContext context, AsyncSnapshot<List<Agave>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Ha ocurrido un error'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No hay tipos de agave disponibles'));
            } else {
              return SafeArea(
                child: ListView.builder(
                  itemCount: snapshot.data?.length,
                  padding: EdgeInsets.only(bottom: 80.0),
                  itemBuilder: (context, index) {
                    var agave = snapshot.data![index];
                    return ListTile(
                      title: Text(agave!.nombre ?? ""),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              bool? check = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistroAgave(
                                    agave: agave,
                                  ),
                                ),
                              );

                              if (check != null && check) {
                                _refresh();
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
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
                  AgaveProvider.db.delete(agave!.id ?? -1, DB.agaves);
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
