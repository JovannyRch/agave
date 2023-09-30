import 'package:flutter/material.dart';

class RegistroEstudio extends StatefulWidget {
  const RegistroEstudio({super.key});

  @override
  _RegistroEstudioState createState() => _RegistroEstudioState();
}

class _RegistroEstudioState extends State<RegistroEstudio> {
  final _formKey = GlobalKey<FormState>();

  // Variables para guardar los valores del formulario
  double? _humedad;
  String? _plaga;
  // ... (otros campos)

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
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Humedad'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _humedad = double.tryParse(value!),
                validator: (value) {
                  // Validaciones
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                items: const [
                  DropdownMenuItem(
                    value: 'Pulgones',
                    child: Text('Pulgones'),
                  ),
                  DropdownMenuItem(
                    value: 'Gusano',
                    child: Text('Gusano'),
                  ),
                  DropdownMenuItem(
                    value: 'Mosca Blanca',
                    child: Text('Mosca Blanca'),
                  ),
                ],
                /* Lista de plagas */
                onChanged: (value) => _plaga = value,
                decoration: const InputDecoration(labelText: 'Plaga a estudiar'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarEstudio,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                child: const Text('Guardar Estudio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _guardarEstudio() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Código para guardar el estudio en la base de datos
    }
  }
}
