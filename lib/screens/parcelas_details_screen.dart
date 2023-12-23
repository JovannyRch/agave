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
import 'package:agave/widgets/submit_button.dart';
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
  EstudiosModel? _estudiosModel;

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
    _estudiosModel = Provider.of<EstudiosModel>(context);
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
          Future.delayed(const Duration(milliseconds: 500), () {
            _refresh();
          });
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
          title: const Text("Desvincular parcela del estudio"),
          content: const Text("¿Estás seguro de desvincular esta parcela?"),
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
                await _estudiosModel
                    ?.desvincularParcela(widget.parcela.id ?? -1);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Desvincular"),
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
              title: "Tipo de planta",
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
      child: (_model!.muestreos.isEmpty && _model!.muestreoNutrientes.isEmpty)
          ? _zeroState()
          : _list(),
    );
  }

  Widget _zeroState() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bug_report,
            size: 75,
            color: kMainColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay muestreos registrados',
          ),
          /* Action button */
          SubmitButton(
            text: 'Registrar Muestreo',
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
          ),
        ],
      ),
    );
  }

  void onClickMuestreo(Muestreo muestreo, int index) {
    _model!.setSelected(muestreo);
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

  void mustreoNutrientes(Muestreo muestreo, int index) {
    _model!.setSelected(muestreo);
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
      itemCount: _model!.muestreos.length + _model!.muestreoNutrientes.length,
      itemBuilder: (context, index) {
        if (index < _model!.muestreos.length) {
          Muestreo muestreo = _model!.muestreos[index];
          return ListItem(
            title: formatDate(muestreo.fechaCreacion ?? ""),
            icon: Icons.bug_report,
            subtitle: muestreo.nombrePlaga ?? "",
            onTap: () {
              onClickMuestreo(muestreo, index);
            },
          );
        }
        Muestreo muestreo =
            _model!.muestreoNutrientes[index - _model!.muestreos.length];
        return ListItem(
          title: formatDate(muestreo.fechaCreacion ?? ""),
          icon: Icons.bug_report,
          subtitle: "Muestreo de Nutrientes",
          onTap: () {
            mustreoNutrientes(muestreo, index);
          },
        );
      },
    );
  }
}
