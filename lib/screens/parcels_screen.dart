import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/screens/parcelas_details_screen.dart';
import 'package:agave/screens/registro_parcela_screen.dart';
import 'package:flutter/material.dart';

class ParcelasScreen extends StatefulWidget {
  const ParcelasScreen({super.key});

  @override
  State<ParcelasScreen> createState() => _ParcelasScreenState();
}

class _ParcelasScreenState extends State<ParcelasScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroParcelaScreen(),
            ),
          );
          setState(() {});
        },
        tooltip: 'Agregar Parcela',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Parcelas'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: FutureBuilder<List<Parcela>>(
          future: ParcelasProvider.db.getAll(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Parcela>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Ha ocurrido un error'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No hay parcelas disponibles'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    /*leading:  Image.network(snapshot.data[index]
                      .rutaImagen), */
                    title: Text(snapshot.data?[index].nombreParcela ?? ""),
                    subtitle: Text(
                        'Tipo de Agave: ${snapshot.data?[index].tipoAgave}'),
                    onTap: () async {
                      Parcela parcela = snapshot.data?[index] ?? Parcela();
                      await Navigator.push(
                        context,
                        await MaterialPageRoute(
                          builder: (context) => DetallesParcela(
                            parcela: parcela,
                          ),
                        ),
                      );
                      _refresh();
                    },
                  );
                },
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
                ParcelasProvider.db.deleteAll(DB.parcels);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
