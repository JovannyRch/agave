import 'package:flutter/material.dart';

class RegistroParcelaScreen extends StatefulWidget {
  const RegistroParcelaScreen({super.key});

  @override
  _RegistroParcelaScreenState createState() => _RegistroParcelaScreenState();
}

class _RegistroParcelaScreenState extends State<RegistroParcelaScreen> {
  final _formKey = GlobalKey<FormState>();

  String? nombreParcela;
  String? tipoAgave;
  double? superficie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Parcela'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Parcela',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un nombre';
                  }
                  return null;
                },
                onSaved: (value) {
                  nombreParcela = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tipo de Agave'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el tipo de agave';
                  }
                  return null;
                },
                onSaved: (value) {
                  tipoAgave = value;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Superficie (hectáreas)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la superficie';
                  }
                  return null;
                },
                onSaved: (value) {
                  superficie = double.tryParse(value!);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Parcela guardada con éxito!')),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
