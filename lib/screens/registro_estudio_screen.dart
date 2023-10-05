import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
import 'package:flutter/material.dart';

class RegistroEstudio extends StatefulWidget {
  final int idParcela;
  RegistroEstudio({required this.idParcela});

  @override
  _RegistroEstudioState createState() => _RegistroEstudioState();
}

class _RegistroEstudioState extends State<RegistroEstudio> {
  final _formKey = GlobalKey<FormState>();

  List<Plaga> _plagas = [];
  double? _humedad;
  int? _plagaId;
  double? _temperatura;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Estudio"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            _humedadInput(),
            _temperaturaInput(),
            _plagaDropdown(),
            const SizedBox(height: 20),
            _submitButton(),
          ]),
        ),
      ),
    );
  }

  Widget _plagaDropdown() {
    return FutureBuilder<List<Plaga>>(
      future: PlagasProvider.db.getAll(),
      builder: (BuildContext context, AsyncSnapshot<List<Plaga>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          List<DropdownMenuItem<int>> items = [];
          for (int i = 0; i < snapshot.data!.length; i++) {
            String nombrePlaga = snapshot.data![i].nombre ?? "";

            if (nombrePlaga.length > 35) {
              nombrePlaga = nombrePlaga.substring(0, 35) + "...";
            }

            items.add(DropdownMenuItem(
              child: Text(nombrePlaga),
              value: snapshot.data![i].id,
            ));
          }

          return DropdownButtonFormField<int>(
            items: items,
            onChanged: (value) => _plagaId = value,
            decoration: const InputDecoration(labelText: 'Plaga a estudiar'),
            validator: (value) => value == null ? 'Selecciona una plaga' : null,
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _humedadInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Humedad'),
      keyboardType: TextInputType.number,
      onSaved: (value) => _humedad = double.tryParse(value!),
      validator: (value) {
        return null;
      },
    );
  }

  Widget _temperaturaInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Temperatura'),
      keyboardType: TextInputType.number,
      onSaved: (value) => _humedad = double.tryParse(value!),
      validator: (value) {
        return null;
      },
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: _guardarEstudio,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          Theme.of(context).primaryColor,
        ),
      ),
      child: const Text('Guardar Estudio'),
    );
  }

  void _guardarEstudio() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Estudio estudio = new Estudio();

      estudio.fechaEstudio = DateTime.now().toString();

      if (_humedad != null) {
        estudio.humedad = _humedad!;
      }

      if (_temperatura != null) {
        estudio.temperatura = _temperatura!;
      }

      if (_plagaId != null) {
        estudio.idEstudio = _plagaId;
      }

      estudio.idParcela = widget.idParcela;
      EstudiosProvider.db.insert(estudio);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudio guardado con éxito!')),
      );
      Navigator.pop(context);
    }
  }
}
