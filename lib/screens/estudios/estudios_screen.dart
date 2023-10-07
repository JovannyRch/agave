import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/screens/estudios/estudio_details_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class EstudiosScreen extends StatefulWidget {
  const EstudiosScreen({super.key});

  @override
  State<EstudiosScreen> createState() => _EstudiosScreenState();
}

class _EstudiosScreenState extends State<EstudiosScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudios'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _listaEstudios(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? check = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroEstudio(),
            ),
          );

          if (check != null && check) {
            _refresh();
          }
        },
        tooltip: 'Crear nuevo estudio',
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _listaEstudios() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder<List<Estudio>>(
        future: EstudiosProvider.db.getAll(),
        builder: (BuildContext context, AsyncSnapshot<List<Estudio>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ha ocurrido un error'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay estudios disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                Estudio estudio = snapshot.data?[index] ?? Estudio();

                return ListTile(
                  title: Text(estudio.nombre ?? ""),
                  subtitle: Text(formatDate(estudio.fechaCreacion)),
                  onTap: () async {
                    Estudio estudio = snapshot.data?[index] ?? Estudio();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstudioDetailsScreen(
                          estudio: estudio,
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
    );
  }
}
