import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroMuestreo extends StatefulWidget {
  int idEstudio;
  int idParcela;
  RegistroMuestreo({required this.idEstudio, required this.idParcela});

  @override
  _RegistroMuestreoState createState() => _RegistroMuestreoState();
}

class _RegistroMuestreoState extends State<RegistroMuestreo> {
  final _formKey = GlobalKey<FormState>();

  double? _humedad;
  int? _idPlaga;
  double? _temperatura;
  String? _nombre;
  PlagasModel? _plagasModel;
  MuestreosModel? _muestreosModel;
  int _tipo = Muestreo.TIPO_PLAGA;

  @override
  Widget build(BuildContext context) {
    _plagasModel = Provider.of<PlagasModel>(context);
    _muestreosModel = Provider.of<MuestreosModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Muestreo"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            _tipoDropdown(),
            if (_tipo == Muestreo.TIPO_PLAGA) _plagaDropdown(),
            _humedadInput(),
            _temperaturaInput(),
            _submitButton(),
          ]),
        ),
      ),
    );
  }

  Widget _tipoDropdown() {
    return DropdownButtonFormField<int>(
      value: _tipo,
      items: [
        DropdownMenuItem<int>(
          value: Muestreo.TIPO_PLAGA,
          child: Text("Incidencias de plaga"),
        ),
        DropdownMenuItem<int>(
          value: Muestreo.TIPO_NUTRIENTES,
          child: Text("Incidencias de nutrientes"),
        ),
      ],
      decoration: const InputDecoration(
        labelText: 'Tipo de muestreo',
        hintText: 'Selecciona una plaga',
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona una plaga';
        }
        return null;
      },
      onChanged: (value) => setState(() {
        _tipo = value!;
      }),
    );
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

  Widget _humedadInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Humedad',
        prefixIcon: Icon(Icons.water),
        suffixText: '%',
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _humedad = double.tryParse(value!),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un valor';
        }

        if (double.tryParse(value) == null) {
          return 'Por favor ingresa un valor numérico';
        }

        if (double.tryParse(value)! < 0 || double.tryParse(value)! > 100) {
          return 'Por favor ingresa un valor entre 0 y 100';
        }

        return null;
      },
    );
  }

  Widget _temperaturaInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Temperatura',
        prefixIcon: Icon(Icons.thermostat),
        suffixText: '°C ',
      ),
      keyboardType: TextInputType.number,
      onSaved: (value) => _temperatura = double.tryParse(value!),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un valor';
        }

        if (double.tryParse(value) == null) {
          return 'Por favor ingresa un valor numérico';
        }

        return null;
      },
    );
  }

  Widget _submitButton() {
    return SubmitButton(
        text: "Registrar",
        onPressed: _tipo == Muestreo.TIPO_PLAGA
            ? _guardarEstudio
            : guardarEstudioNutrientes);
  }

  void guardarEstudioNutrientes() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Muestreo muestreo = Muestreo(
        idEstudio: widget.idEstudio,
        idParcela: widget.idParcela,
        tipo: Muestreo.TIPO_NUTRIENTES,
      );

      if (_humedad != null) {
        muestreo.humedad = _humedad;
      }

      if (_temperatura != null) {
        muestreo.temperatura = _temperatura;
      }

      _muestreosModel?.add(muestreo);
      _muestreosModel?.fetchData(widget.idEstudio, widget.idParcela);
      Navigator.pop(context);
    }
  }

  void _guardarEstudio() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Muestreo muestreo = Muestreo(
        idEstudio: widget.idEstudio,
        idParcela: widget.idParcela,
        idPlaga: _idPlaga!,
        tipo: Muestreo.TIPO_PLAGA,
      );

      if (_humedad != null) {
        muestreo.humedad = _humedad;
      }

      if (_temperatura != null) {
        muestreo.temperatura = _temperatura;
      }

      _muestreosModel?.add(muestreo);
      _muestreosModel?.fetchData(widget.idEstudio, widget.idParcela);

      Navigator.pop(context);
    }
  }
}
