import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/screens/registro_parcela_screen.dart';
import 'package:flutter/material.dart';

class ParcelasScreen extends StatelessWidget {
  const ParcelasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const RegistroParcelaScreen()),
          );
        },
        tooltip: 'Agregar Parcela',
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Parcelas'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: ParcelasProvider.db.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<Parcela>> snapshot) {
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
                  subtitle:
                      Text('Tipo de Agave: ${snapshot.data?[index].tipoAgave}'),
                  onTap: () {
                    // Acciones al tocar una parcela, por ejemplo, navegar a detalles
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar todas las parcelas'),
          content: Text(
              '¿Estás seguro de que quieres eliminar todas las parcelas registradas? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red)),
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
