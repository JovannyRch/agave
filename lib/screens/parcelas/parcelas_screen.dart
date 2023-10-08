import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/screens/parcelas/registro_parcela_screen.dart';
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
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              _estudiosModel!.addParcela(list[index]);
              Navigator.pop(context);
            },
          ),
          subtitle: Text('${list[index].tipoAgave}'),
        );
      },
    );

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: list.isEmpty
          ? Center(
              child: Text(
                _searchText.isEmpty
                    ? 'No hay parcelas registradas'
                    : 'No hay resultados para la búsqueda',
              ),
            )
          : listBuilder,
    );
  }

  Future<void> _refresh() async {
    Provider.of<ParcelaModel>(context, listen: false).fetchData();
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
