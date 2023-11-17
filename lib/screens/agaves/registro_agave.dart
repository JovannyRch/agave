import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistroAgave extends StatefulWidget {
  final Agave? agave;

  const RegistroAgave({super.key, this.agave});

  @override
  _RegistroAgaveState createState() => _RegistroAgaveState();
}

class _RegistroAgaveState extends State<RegistroAgave> {
  final _formKey = GlobalKey<FormState>();
  String _nombre = '';
  bool isEditing = false;
  AgavesModel? _model;

  @override
  void initState() {
    super.initState();
    if (widget.agave != null) {
      isEditing = true;
      _nombre = widget.agave!.nombre!;
    }
  }

  @override
  Widget build(BuildContext context) {
    _model = Provider.of<AgavesModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Tipo de Planta'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Nombre del tipo de planta'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el nombre del tipo de planta';
                  }
                  return null;
                },
                initialValue: _nombre,
                onSaved: (value) {
                  _nombre = value!;
                },
              ),
              SubmitButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    Agave item = isEditing
                        ? Agave(id: widget.agave!.id, nombre: _nombre)
                        : Agave(nombre: _nombre);

                    if (isEditing) {
                      _model?.update(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tipo de planta $_nombre actualizada!'),
                        ),
                      );
                    } else {
                      _model?.add(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Tipo de planta $_nombre registrada!'),
                        ),
                      );
                    }

                    Navigator.pop(context, true);
                  }
                },
                text: isEditing ? 'Actualizar' : 'Registrar',
              )
            ],
          ),
        ),
      ),
    );
  }
}
