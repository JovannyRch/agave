import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/screens/parcelas/parcels_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class EstudioDetailsScreen extends StatefulWidget {
  Estudio estudio;
  EstudioDetailsScreen({super.key, required this.estudio});

  @override
  State<EstudioDetailsScreen> createState() => _EstudioDetailsScreenState();
}

class _EstudioDetailsScreenState extends State<EstudioDetailsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late Estudio estudio;
  Size? size;

  @override
  void initState() {
    estudio = widget.estudio;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              builder: (context) => ParcelasScreen(),
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
              'Nombre: ${widget.estudio.nombre}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Fecha de Creación: ${formatDate(estudio!.fechaCreacion)}',
            ),
            _renderObservaciones(),
            // Aquí puede ir la lista de Parcelas Asociadas
            SizedBox(
              height: size!.height * 0.7,
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
    if (estudio!.observaciones == null || estudio!.observaciones == "") {
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
        Text(estudio!.observaciones ?? ""),
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
                await EstudiosProvider.db
                    .delete(estudio!.id ?? -1, DB.estudios);
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
      onPressed: () async {
        Estudio? updatedEstudio = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistroEstudio(
              estudio: estudio,
            ),
          ),
        );
        if (updatedEstudio != null) {
          setState(() {
            estudio = updatedEstudio;
          });
        }
      },
    );
  }

  Widget _detalleParcela() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          estudio!.nombre ?? "",
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        _renderObservaciones(),
      ],
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _listaParcelas() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder<List<Parcela>>(
        future: ParcelasProvider.db.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<Parcela>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Ha ocurrido un error al obtener las parcelas asociadas',
              ),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay parcelas asociadas'),
            );
          } else {
            Widget list = ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: const Text("Estudio"),
                  subtitle: Text(
                    formatDate(snapshot.data?[index].fechaCreacion),
                  ),
                  onTap: () {
                    /* Estudio estudio = snapshot.data?[index] ?? Estudio();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstudioDetailsScreen(
                          estudio: estudio,
                        ),
                      ),
                    ); */
                  },
                );
              },
            );

            return Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Parcelas Asociadas:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                list,
              ],
            );
          }
        },
      ),
    );
  }
}
