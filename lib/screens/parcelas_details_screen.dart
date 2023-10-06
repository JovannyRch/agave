import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/screens/estudio_details_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:agave/screens/registro_parcela_screen.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class DetallesParcela extends StatefulWidget {
  Parcela parcela;
  DetallesParcela({super.key, required this.parcela});

  @override
  State<DetallesParcela> createState() => _DetallesParcelaState();
}

class _DetallesParcelaState extends State<DetallesParcela> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Parcela? parcela;

  @override
  void initState() {
    parcela = widget.parcela;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Detalles Parcela'),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Detalles"),
              Tab(text: "Estudios"),
            ],
            indicatorColor: Colors.white,
          ),
          actions: [
            _deleteButton(),
            _editButton(),
          ],
        ),
        body: TabBarView(
          children: [
            _detalleParcela(),
            _listaEstudios(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistroEstudio(
                  idParcela: parcela!.id ?? -1,
                ),
              ),
            );
            setState(() {});
          },
          child: const Icon(Icons.add),
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

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Eliminar Parcela"),
          content: const Text("¿Estás seguro de eliminar esta parcela?"),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Eliminar"),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                await ParcelasProvider.db.deleteOne(parcela!.id ?? -1);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistroParcelaScreen(
              parcela: parcela,
            ),
          ),
        );
        Parcela? editedParcel =
            await ParcelasProvider.db.getById(parcela!.id ?? -1);
        setState(() {
          parcela = editedParcel;
        });
      },
    );
  }

  Widget _detalleParcela() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          parcela!.nombre ?? "",
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20.0),
        parcela!.tipoAgave == null || parcela!.tipoAgave == ""
            ? Container()
            : Card(
                child: ListTile(
                  title: const Text("Tipo de Agave"),
                  subtitle: Text(parcela!.tipoAgave ?? ""),
                ),
              ),
        Card(
          child: ListTile(
            title: const Text("Superficie"),
            subtitle: Text("${parcela!.superficie} ha"),
          ),
        ),
        parcela!.estadoCultivo == null || parcela!.estadoCultivo == ""
            ? Container()
            : Card(
                child: ListTile(
                  title: const Text("Estado del Cultivo"),
                  subtitle: Text(parcela!.estadoCultivo ?? ""),
                ),
              ),
        _renderObservaciones(),
      ],
    );
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Widget _renderObservaciones() {
    if (parcela!.observaciones == null || parcela!.observaciones == "") {
      return Container();
    }

    return Column(
      children: [
        const SizedBox(height: 20.0),
        const Text(
          "Observaciones",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Text(parcela!.observaciones ?? ""),
      ],
    );
  }

  Widget _listaEstudios() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: FutureBuilder<List<Estudio>>(
        future: EstudiosProvider.db.getAllWithPlague(parcela!.id ?? -1),
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
                return ListTile(
                  title: Text("Estdio"),
                  subtitle:
                      Text(formatDate(snapshot.data?[index].fechaCreacion)),
                  onTap: () {
                    Estudio estudio = snapshot.data?[index] ?? Estudio();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EstudioDetailsScreen(
                          estudio: estudio,
                        ),
                      ),
                    );
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
