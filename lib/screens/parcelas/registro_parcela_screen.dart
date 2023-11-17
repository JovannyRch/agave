import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroParcelaScreen extends StatefulWidget {
  Parcela? parcela;

  RegistroParcelaScreen({super.key, this.parcela});

  @override
  _RegistroParcelaScreenState createState() => _RegistroParcelaScreenState();
}

class _RegistroParcelaScreenState extends State<RegistroParcelaScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  int? _idAgave;
  String? _nombreParcela = "";
  double? _superficie;
  String? _selectedEstadoCultivo = "";
  String? _observaciones = "";
  ParcelaModel? _model;

  @override
  void initState() {
    if (widget.parcela != null) {
      isEditing = true;
      _nombreParcela = widget.parcela!.nombre;
      _superficie = widget.parcela!.superficie;
      _idAgave = widget.parcela!.idTipoAgave;
      _selectedEstadoCultivo = widget.parcela!.estadoCultivo;
      _observaciones = widget.parcela!.observaciones;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final agavesModel = Provider.of<AgavesModel>(context);
    _model = Provider.of<ParcelaModel>(context);
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
              _tipoDrowdown(agavesModel.agaves),
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

  Widget _superficieInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Superficie (m²)'),
      keyboardType: TextInputType.number,
      initialValue: _superficie != null ? _superficie.toString() : "",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa la superficie';
        }
        return null;
      },
      onSaved: (value) {
        _superficie = double.tryParse(value!);
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
      initialValue: _nombreParcela,
      onSaved: (value) {
        _nombreParcela = value;
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

  Widget _tipoDrowdown(List<Agave> list) {
    return DropdownButtonFormField<int>(
      value: _idAgave,
      items: list.map((agave) {
        return DropdownMenuItem<int>(
          value: agave.id,
          child: Text(agave.nombre ?? ""),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _idAgave = value;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Tipo de planta',
        hintText: 'Selecciona un tipo de planta',
      ),
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona un tipo de planta';
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
            nombre: _nombreParcela!,
            superficie: _superficie!,
            observaciones: _observaciones!,
          );

          if (_idAgave != null) {
            parcela.idTipoAgave = _idAgave;
          }

          if (_selectedEstadoCultivo != null) {
            parcela.estadoCultivo = _selectedEstadoCultivo!;
          }

          if (isEditing) {
            parcela.id = widget.parcela!.id;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parcela actualizada con éxito!')),
            );
          } else {
            _model!.add(parcela);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Parcela guardada con éxito!')),
            );
          }

          Navigator.pop(context);
        }
      },
      child: Text(isEditing ? 'Actualizar' : 'Registrar'),
    );
  }
}
