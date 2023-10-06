import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
import 'package:flutter/material.dart';

class RegistroMuestreo extends StatefulWidget {
  @override
  _RegistroMuestreoState createState() => _RegistroMuestreoState();
}

class _RegistroMuestreoState extends State<RegistroMuestreo> {
  final _formKey = GlobalKey<FormState>();

  final List<Plaga> _plagas = [];
  double? _humedad;
  int? _plagaId;
  double? _temperatura;
  String? _nombre;

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
            _plagaDropdown(),
            _humedadInput(),
            _temperaturaInput(),
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
              nombrePlaga = "${nombrePlaga.substring(0, 35)}...";
            }

            items.add(DropdownMenuItem(
              value: snapshot.data![i].id,
              child: Text(nombrePlaga),
            ));
          }

          return DropdownButtonFormField<int>(
            items: items,
            onChanged: (value) => _plagaId = value,
            decoration: const InputDecoration(labelText: 'Plaga a estudiar'),
            validator: (value) => value == null ? 'Selecciona una plaga' : null,
          );
        } else {
          return const CircularProgressIndicator();
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

  void _guardarEstudio() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Estudio estudio = Estudio();

      estudio.fechaCreacion = DateTime.now().toString();

      EstudiosProvider.db.insert(estudio);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudio guardado con éxito!')),
      );
      Navigator.pop(context);
    }
  }
}
