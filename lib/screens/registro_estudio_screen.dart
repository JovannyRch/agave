import 'package:agave/backend/models/actividad.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/widgets/actividad_item.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroEstudio extends StatefulWidget {
  Estudio? estudio;
  RegistroEstudio({Key? key, this.estudio}) : super(key: key);

  @override
  _RegistroEstudioState createState() => _RegistroEstudioState();
}

class _RegistroEstudioState extends State<RegistroEstudio> {
  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  String? _observaciones;
  Estudio? estudio;
  bool isEditing = false;
  EstudiosModel? _model;

  @override
  void initState() {
    super.initState();
    if (widget.estudio != null) {
      isEditing = true;
      estudio = widget.estudio;
      _nombre = estudio!.nombre;
      _observaciones = estudio!.observaciones;
    }
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<EstudiosModel>(context);
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
            _submitButton(),
          ]),
        ),
      ),
    );
  }

  Widget _nombreInput() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Nombre'),
      initialValue: _nombre,
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
    return SubmitButton(
        text: isEditing ? 'Guardar cambios' : 'Guardar estudio',
        onPressed: _guardarEstudio);
  }

  void _guardarEstudio() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (isEditing) {
        _updateEstudio();
      } else {
        _saveEstudio();
      }
    }
  }

  void _updateEstudio() async {
    Estudio estudio = widget.estudio!;

    estudio.nombre = _nombre;
    estudio.observaciones = _observaciones ?? "";

    _model?.update(estudio);
    _model?.setSelected(estudio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudio actualizado con éxito!')),
    );

    Navigator.pop(context);
  }

  void _saveEstudio() async {
    Estudio estudio = Estudio();

    estudio.fechaCreacion = DateTime.now().toString();
    estudio.nombre = _nombre;

    if (_observaciones != null) {
      estudio.observaciones = _observaciones;
    }

    _model?.add(estudio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Estudio guardado con éxito!')),
    );
    Navigator.pop(context);
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
