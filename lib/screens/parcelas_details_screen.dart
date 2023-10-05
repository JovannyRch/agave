import 'package:agave/backend/models/parcela.dart';
import 'package:agave/screens/estudio_details_screen.dart';
import 'package:agave/screens/registro_estudio_screen.dart';
import 'package:flutter/material.dart';

class DetallesParcela extends StatefulWidget {
  Parcela parcela;
  DetallesParcela({super.key, required this.parcela});

  @override
  State<DetallesParcela> createState() => _DetallesParcelaState();
}

class _DetallesParcelaState extends State<DetallesParcela> {
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
        ),
        body: TabBarView(
          children: [
            _detalleParcela(),
            _listaEstudios(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            //Navigate to RegistroEstudio
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistroEstudio(
                  idParcela: widget.parcela.id ?? -1,
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _detalleParcela() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text(
          widget.parcela.nombreParcela ?? "",
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20.0),
        widget.parcela.tipoAgave == null || widget.parcela.tipoAgave == ""
            ? Container()
            : Card(
                child: ListTile(
                  title: const Text("Tipo de Agave"),
                  subtitle: Text(widget.parcela.tipoAgave ?? ""),
                ),
              ),
        Card(
          child: ListTile(
            title: const Text("Superficie"),
            subtitle: Text("${widget.parcela.superficie} ha"),
          ),
        ),
        widget.parcela.estadoCultivo == null ||
                widget.parcela.estadoCultivo == ""
            ? Container()
            : Card(
                child: ListTile(
                  title: const Text("Estado del Cultivo"),
                  subtitle: Text(widget.parcela.estadoCultivo ?? ""),
                ),
              ),
        const SizedBox(height: 20.0),
        Text(
          "Observaciones",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        Text(widget.parcela.observaciones ?? ""),
      ],
    );
  }

  Widget _listaEstudios() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Estudio ${index + 1}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EstudioDetailsScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
