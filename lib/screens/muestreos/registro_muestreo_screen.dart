import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroMuestreoScreen extends StatefulWidget {
  int idParcela;
  int idEstudio;

  RegistroMuestreoScreen({required this.idParcela, required this.idEstudio});

  @override
  State<RegistroMuestreoScreen> createState() => _RegistroMuestreoScreenState();
}

class _RegistroMuestreoScreenState extends State<RegistroMuestreoScreen> {
  MuestreosModel? _model;
  PlagasModel? _plagasModel;
  final _formKey = GlobalKey<FormState>();
  int? _idPlaga;

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<MuestreosModel>(context);
    _plagasModel = Provider.of<PlagasModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Muestreo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _plagaDropdown(),
              const SizedBox(height: 20),
              SubmitButton(
                text: "Registrar",
                onPressed: _saveMuestreo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMuestreo() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Muestreo muestreo = Muestreo(
        idParcela: widget.idParcela,
        idEstudio: widget.idEstudio,
        idPlaga: _idPlaga,
      );
      _model!.add(muestreo);

      Navigator.pop(context);
    }
  }

  Widget _plagaDropdown() {
    return DropdownButtonFormField<int>(
      value: _idPlaga,
      items: _plagasModel!.plagas.map((plaga) {
        return DropdownMenuItem<int>(
          value: plaga.id,
          child: Text(plaga.nombre ?? ""),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _idPlaga = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Plaga',
        hintText: 'Selecciona una plaga',
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una plaga';
        }
        return null;
      },
    );
  }
}
