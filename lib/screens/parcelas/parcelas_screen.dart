import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/parcelas/registro_parcela_screen.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParcelasScreen extends StatefulWidget {
  const ParcelasScreen({super.key});

  @override
  State<ParcelasScreen> createState() => _ParcelasScreenState();
}

class _ParcelasScreenState extends State<ParcelasScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  String _searchText = "";
  ParcelaModel? _model;
  EstudiosModel? _estudiosModel;

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<ParcelaModel>(context);
    _estudiosModel = Provider.of<EstudiosModel>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroParcelaScreen(),
            ),
          );
        },
        tooltip: 'Agregar Parcela',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Parcelas'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          _search(),
          Expanded(
            child: _list(),
          ),
        ],
      ),
    );
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar parcela',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchText = value;
          });
        },
      ),
    );
  }

  Widget _list() {
    List<Parcela> list = _model?.parcelas ?? [];

    if (_searchText.isNotEmpty) {
      list = list
          .where((element) => element.nombre!.contains(_searchText))
          .toList();
    }

    var listBuilder = ListView.builder(
      itemCount: list.length,
      padding: const EdgeInsets.only(bottom: 100.0),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(list[index].nombre ?? ""),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    bool ok = await _estudiosModel!.addParcela(list[index]);

                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Parcela agregada correctamente'),
                        ),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('La parcela ya está asociada'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Eliminar parcela'),
                          content: const Text(
                              '¿Estás seguro de que quieres eliminar esta parcela y sus registros? Esta acción no se puede deshacer.'),
                          actions: [
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                _model?.delete(list[index].id ?? -1);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          subtitle: Text('${list[index].tipoAgave}'),
        );
      },
    );

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: list.isEmpty ? _zeroState() : listBuilder,
    );
  }

  Future<void> _refresh() async {
    Provider.of<ParcelaModel>(context, listen: false).fetchData();
  }

  Widget _zeroState() {
    if (_searchText.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.nature,
              size: 100.0,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              'Aún no hay parcelas registradas',
            ),
            SubmitButton(
              text: 'Registrar Parcela',
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistroParcelaScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.nature,
            size: 100.0,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 20.0,
          ),
          const Text(
            'No hay resultados para la búsqueda',
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar todas las parcelas'),
          content: const Text(
              '¿Estás seguro de que quieres eliminar todas las parcelas registradas? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                ParcelasProvider.db.deleteAll(DB.parcelas);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
