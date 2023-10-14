import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/list_item.dart';
import 'package:agave/widgets/screen_title.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/muestreos/muestreo_details_screen.dart';
import 'package:agave/screens/muestreos/registro_muestreo_screen.dart';
import 'package:agave/screens/parcelas/registro_parcela_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/formatDate.dart';

class DetallesParcela extends StatefulWidget {
  Parcela parcela;
  Estudio estudio;
  DetallesParcela({super.key, required this.parcela, required this.estudio});

  @override
  State<DetallesParcela> createState() => _DetallesParcelaState();
}

class _DetallesParcelaState extends State<DetallesParcela> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Parcela? parcela;
  Estudio? estudio;
  MuestreosModel? _model;

  @override
  void initState() {
    parcela = widget.parcela;
    estudio = widget.estudio;
    _refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<MuestreosModel>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Detalles Parcela'),
        /*   bottom: const TabBar(
          tabs: [
            Tab(text: "Detalles"),
            Tab(text: "Muestreos"),
          ],
          indicatorColor: Colors.white,
        ), */
        actions: [
          _deleteButton(),
          _editButton(),
        ],
      ),
      body: _body(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroMuestreo(
                idEstudio: widget.estudio.id ?? -1,
                idParcela: widget.parcela.id ?? -1,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
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
                await ParcelasProvider.db.deleteOne(parcela!.id ?? -1);
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

  Widget _body() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ScreenTitle(
          title: widget.parcela.nombre ?? "",
          subtitle: widget.estudio.nombre,
        ),
        if (parcela!.tipoAgave != null && parcela!.tipoAgave!.isNotEmpty)
          Card(
            child: CardDetail(
              title: "Tipo de Agave",
              value: parcela!.tipoAgave ?? "",
            ),
          ),
        if (parcela!.estadoCultivo != null &&
            parcela!.estadoCultivo!.isNotEmpty)
          Card(
            child: CardDetail(
              title: "Estado de Cultivo",
              value: parcela!.estadoCultivo ?? "",
            ),
          ),
        Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CardDetail(
                title: "Superficie",
                value: "${parcela!.superficie}",
                unit: " m²",
              ),
              CardDetail(
                title: "Muestreos",
                value: "${(_model!.muestreos.length).toString()}",
              ),
            ],
          ),
        ),
        _renderObservaciones(),
        const SizedBox(height: 20.0),
        const Text(
          "Muestreos",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.0),
        ..._renderMuestreos(),
      ],
    );
  }

  List<Widget> _renderMuestreos() {
    return [
      Container(
        height: 300,
        child: _listaMuestreos(),
      )
    ];
  }

  Future<void> _refresh() async {
    Provider.of<MuestreosModel>(context, listen: false)
        .fetchData(widget.estudio.id ?? -1, widget.parcela.id ?? -1);
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

  Widget _listaMuestreos() {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _refresh,
      child: _model!.muestreos.isEmpty ? _emptyList() : _list(),
    );
  }

  Widget _emptyList() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bug_report,
            size: 50,
            color: Colors.black45,
          ),
          SizedBox(height: 20),
          Text(
            "No hay muestreos registrados",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  void onClickMuestreo(Muestreo muestreo, int index) {
    _model!.setSelected(muestreo);
    _model!.selectedMuestreo!.hacerCalculos();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MuestreoDetailsScreen(
          muestreo: muestreo,
          parcela: parcela!,
          estudio: widget.estudio,
        ),
      ),
    );
  }

  Widget _list() {
    return ListView.builder(
      itemCount: _model!.muestreos.length,
      itemBuilder: (context, index) {
        Muestreo muestreo = _model!.muestreos[index];
        return ListItem(
            title: muestreo!.nombrePlaga ?? "",
            subtitle: formatDate(muestreo.fechaCreacion),
            icon: Icons.bug_report,
            onTap: () {
              onClickMuestreo(muestreo, index);
            });
      },
    );
  }
}
