import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/plagas_provider.dart';
import 'package:agave/backend/widgets/submit_button.dart';
import 'package:flutter/material.dart';

class RegistroPlaga extends StatefulWidget {
  final Plaga? plaga;

  RegistroPlaga({this.plaga});

  @override
  _RegistroPlagaState createState() => _RegistroPlagaState();
}

class _RegistroPlagaState extends State<RegistroPlaga> {
  final _formKey = GlobalKey<FormState>();
  String _nombrePlaga = '';
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.plaga != null) {
      isEditing = true;
      _nombrePlaga = widget.plaga!.nombre!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Plaga'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de la plaga'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el nombre de la plaga';
                  }
                  return null;
                },
                initialValue: _nombrePlaga,
                onSaved: (value) {
                  _nombrePlaga = value!;
                },
              ),
              SubmitButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    Plaga plaga = isEditing
                        ? Plaga(id: widget.plaga!.id, nombre: _nombrePlaga)
                        : Plaga(nombre: _nombrePlaga);

                    if (isEditing) {
                      PlagasProvider.db.update(plaga);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plaga $_nombrePlaga actualizada!'),
                        ),
                      );
                    } else {
                      PlagasProvider.db.insert(plaga);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Plaga $_nombrePlaga registrada!'),
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
