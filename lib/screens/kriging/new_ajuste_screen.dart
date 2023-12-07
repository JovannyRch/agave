import 'dart:convert';

import 'package:agave/api/api.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/const.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/card_image.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewAjusteScreen extends StatefulWidget {
  final List<List<double>> points;
  final int idMuestreo;

  const NewAjusteScreen({
    Key? key,
    required this.points,
    required this.idMuestreo,
  }) : super(key: key);

  @override
  State<NewAjusteScreen> createState() => _NewAjusteScreenState();
}

class _NewAjusteScreenState extends State<NewAjusteScreen> {
  TextEditingController _nLagsController = TextEditingController();
  VariogramModel selectedModel = VariogramModel.spherical;
  final _formKey = GlobalKey<FormState>();

  SemivariogramaResponse? _semivariogramaResponse;
  bool _isLoadingSemivariogram = false;
  late AjustesModel _ajustesModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajuste'),
        backgroundColor: kMainColor,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    _ajustesModel = Provider.of<AjustesModel>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          _initialForm(),
          !_isLoadingSemivariogram && _semivariogramaResponse == null
              ? Container()
              : _renderSemivariogram(),
        ],
      ),
    );
  }

  Widget _initialForm() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //N Lags
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Número de lags',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un valor';
                  }

                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un valor entero';
                  }

                  return null;
                },
                controller: _nLagsController,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<VariogramModel>(
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
                value: selectedModel,
                onChanged: (VariogramModel? newValue) {
                  setState(() {
                    selectedModel = newValue!;
                  });
                },
                items: VariogramModel.values
                    .map<DropdownMenuItem<VariogramModel>>(
                        (VariogramModel value) {
                  return DropdownMenuItem<VariogramModel>(
                    value: value,
                    child: Text(
                      getModelName(value),
                    ),
                  );
                }).toList(),
              ),
              SubmitButton(
                text: 'Obtener semivariograma',
                onPressed: _getSemivariogram,
              ),
            ],
          ),
        ));
  }

  void _getSemivariogram() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int nLags = int.parse(_nLagsController.text);

      setState(() {
        _isLoadingSemivariogram = true;
      });

      try {
        _semivariogramaResponse = await Api.getExperimentalSemivariogram(
          widget.points,
          nLags,
        );
        //Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Semivariograma obtenido, el ajuste se ha realizado automáticamente'),
          ),
        );
      } catch (e) {
        //Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener el semivariograma'),
          ),
        );
      } finally {
        setState(() {
          _isLoadingSemivariogram = false;
        });
      }
    }
  }

  Widget _renderSemivariogram() {
    if (_isLoadingSemivariogram) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        Divider(),
        const Text(
          'Semivariograma ajustado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Base64CardImage(
          image: _semivariogramaResponse!.image_base64 ?? "",
          title: 'Semivariograma',
        ),
        _rowDetails(),
        const SizedBox(height: 20),
        _rowActions(),
      ],
    );
  }

  Widget _rowActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: RoundedButton(
            onPressed: () {
              Navigator.pop(context, _semivariogramaResponse);
            },
            icon: Icons.draw,
            text: 'Ajuste manual',
          ),
        ),
        Expanded(
          child: RoundedButton(
            onPressed: () {
              _save();
            },
            icon: Icons.save,
            text: 'Guardar',
          ),
        ),
        Expanded(
          child: RoundedButton(
            onPressed: () {
              Navigator.pop(context, _semivariogramaResponse);
            },
            icon: Icons.map,
            text: 'Mapa de contorno',
          ),
        ),
      ],
    );
  }

  Widget _rowDetails() {
    return Row(
      children: [
        Expanded(
          child: CardDetail(
            title: "Rango",
            value: _semivariogramaResponse!.range!.toStringAsFixed(3),
            color: Colors.transparent,
            isCenter: true,
          ),
        ),
        Expanded(
          child: CardDetail(
            title: "Meseta",
            value: _semivariogramaResponse!.sill!.toStringAsFixed(3),
            color: Colors.transparent,
            isCenter: true,
          ),
        ),
        Expanded(
          child: CardDetail(
            title: "Nugget",
            value: _semivariogramaResponse!.nugget!.toStringAsFixed(3),
            color: Colors.transparent,
            isCenter: true,
          ),
        ),
      ],
    );
  }

  void _save() async {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar ajuste"),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: "Nombre del ajuste",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kMainColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kMainColor,
              ),
              onPressed: () {
                _saveAjuste(_controller.text);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void _saveAjuste(String nombre) async {
    try {
      Ajuste ajuste = Ajuste(
        modelo: selectedModel.toString().split('.').last,
        sill: _semivariogramaResponse!.sill,
        range: _semivariogramaResponse!.range,
        nugget: _semivariogramaResponse!.nugget,
        muestreoId: widget.idMuestreo,
        nombre: nombre,
      );
      _ajustesModel!.add(ajuste);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajuste guardado'),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No se pudo guardar el ajuste, revise los datos valores del modelo'),
        ),
      );
    }
  }
}
