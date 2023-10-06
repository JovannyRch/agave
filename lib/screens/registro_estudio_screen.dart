import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/providers/estudios_provider.dart';
import 'package:flutter/material.dart';

class RegistroEstudio extends StatefulWidget {
  @override
  _RegistroEstudioState createState() => _RegistroEstudioState();
}

class _RegistroEstudioState extends State<RegistroEstudio> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  String? _observaciones;

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
            _nombreInput(),
            _obervacionesInput(),
            const SizedBox(height: 20),
            _submitButton(),
          ]),
        ),
      ),
    );
  }

  Widget _nombreInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Nombre'),
      keyboardType: TextInputType.number,
      onSaved: (value) => _nombre = value,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa un nombre';
        }
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
      estudio.nombre = _nombre;

      if (_observaciones != null) {
        estudio.observaciones = _observaciones;
      }

      await EstudiosProvider.db.insert(estudio);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estudio guardado con éxito!')),
      );
      Navigator.pop(context);
    }
  }

  Widget _obervacionesInput() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Observaciones',
        hintText: 'Ingresa cualquier detalle o nota adicional sobre la parcela',
      ),
      maxLines: 5, // Permite que el input tenga varias líneas
      keyboardType: TextInputType.multiline,
      initialValue: _observaciones,
      onSaved: (value) {
        _observaciones = value;
      },
    );
  }
}
