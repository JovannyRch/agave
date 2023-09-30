import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
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
  String? _selectedAgave;
  String? _selectedEstadoCultivo = "";
  String? _observaciones = "";

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
              _nombreInput(),
              _superficieInput(),
              _tipoDrowdown(),
              _statusDropdown(),
              _obervacionesInput(),
              const SizedBox(height: 20),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _obervacionesInput() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Observaciones',
        hintText: 'Ingresa cualquier detalle o nota adicional sobre la parcela',
      ),
      maxLines: 5, // Permite que el input tenga varias líneas
      keyboardType: TextInputType.multiline,
      onSaved: (value) {
        _observaciones = value;
      },
    );
  }

  Widget _superficieInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Superficie (hectáreas)'),
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
    );
  }

  Widget _nombreInput() {
    return TextFormField(
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
    );
  }

  Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedEstadoCultivo,
      items: const [
        DropdownMenuItem(
          value: "",
          child: Text("No especificado"),
        ),
        DropdownMenuItem(
          value: "Recién plantado",
          child: Text("Recién plantado"),
        ),
        DropdownMenuItem(
            value: "En crecimiento", child: Text("En crecimiento")),
        DropdownMenuItem(value: "Maduro", child: Text("Maduro")),
        DropdownMenuItem(value: "En cosecha", child: Text("En cosecha")),
        DropdownMenuItem(value: "En barbecho", child: Text("En barbecho")),
        DropdownMenuItem(value: "Abandonado", child: Text("Abandonado")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedEstadoCultivo = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Estado del Cultivo',
        hintText: 'Selecciona el estado del cultivo',
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona un estado del cultivo';
        }

        return null;
      },
    );
  }

  Widget _tipoDrowdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAgave,
      items: const [
        DropdownMenuItem(
            value: "Agave tequilana", child: Text("Agave tequilana (Azul)")),
        DropdownMenuItem(
            value: "Agave angustifolia",
            child: Text("Agave angustifolia (Espadín)")),
        DropdownMenuItem(
            value: "Agave salmiana", child: Text("Agave salmiana")),
        DropdownMenuItem(
            value: "Agave americana", child: Text("Agave americana")),
        DropdownMenuItem(
            value: "Agave potatorum", child: Text("Agave potatorum (Tobala)")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAgave = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Tipo de Agave',
        hintText: 'Selecciona un tipo de agave',
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona un tipo de agave';
        }
        return null;
      },
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          Parcela parcela = Parcela(
            nombreParcela: nombreParcela!,
            superficie: superficie!,
            fechaCreacion: DateTime.now().toString(),
            observaciones: _observaciones!,
          );

          if (_selectedAgave != null) {
            parcela.tipoAgave = _selectedAgave!;
          }

          if (_selectedEstadoCultivo != null) {
            parcela.estadoCultivo = _selectedEstadoCultivo!;
          }

          ParcelasProvider.db.insert(parcela);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Parcela guardada con éxito!')),
          );

          Navigator.pop(context);
        }
      },
      child: const Text('Guardar'),
    );
  }
}
