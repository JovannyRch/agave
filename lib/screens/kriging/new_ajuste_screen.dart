// ignore_for_file: use_build_context_synchronously

import 'package:agave/api/api.dart';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/api/responses/semivariograma_response.dart';
import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/kriging/ajuste_manual.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/card_image.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewAjusteScreen extends StatefulWidget {
  final List<List<double>> points;
  final int idMuestreo;

  final Ajuste? ajuste;
  String? nutriente;

  NewAjusteScreen({
    Key? key,
    required this.points,
    required this.idMuestreo,
    this.ajuste,
    this.nutriente,
  }) : super(key: key);

  @override
  State<NewAjusteScreen> createState() => _NewAjusteScreenState();
}

class _NewAjusteScreenState extends State<NewAjusteScreen> {
  TextEditingController _nLagsController = TextEditingController();
  VariogramModel selectedModel = VariogramModel.spherical;
  final _formKey = GlobalKey<FormState>();

  SemivariogramaResponse? _semivariogramaResponse;
  KrigingContourResponse? _krigingContourResponse;

  bool _isLoadingSemivariogram = false;
  bool _isLoadingKrigingContour = false;
  late AjustesModel _ajustesModel;
  bool isEditing = false;

  @override
  void initState() {
    setState(() {
      isEditing = widget.ajuste != null;
      if (isEditing) {
        _semivariogramaResponse = SemivariogramaResponse(
          lags: [],
          semivariance: [],
          image_base64: widget.ajuste?.semivariogramImage,
          sill: widget.ajuste?.sill,
          range: widget.ajuste?.range,
          nugget: widget.ajuste?.nugget,
        );
        //Check if contour image is not null
        if (widget.ajuste?.contourImage != null &&
            widget.ajuste?.contourImage != "") {
          _krigingContourResponse = KrigingContourResponse(
            image_base64: widget.ajuste?.contourImage,
          );
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _ajustesModel = Provider.of<AjustesModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(!isEditing ? 'Nuevo ajuste' : widget.ajuste!.nombre!),
        backgroundColor: kMainColor,
        actions: _actions(),
      ),
      body: _body(),
    );
  }

  List<Widget> _actions() {
    if (widget.ajuste != null) {
      return [
        IconButton(
          onPressed: () {
            //Show delete dialog
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Eliminar ajuste"),
                  content: const Text(
                      "¿Está seguro que desea eliminar este ajuste?"),
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
                        Navigator.pop(context);
                        _delete();
                      },
                      child: const Text("Eliminar"),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.delete),
        ),
      ];
    }
    return [];
  }

  void _delete() async {
    try {
      await _ajustesModel!.delete(widget!.ajuste!.id ?? -1);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajuste eliminado'),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar el ajuste'),
        ),
      );
    }
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!isEditing) _initialForm(),
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

  void _getKrigingContour() async {
    setState(() {
      _isLoadingKrigingContour = true;
    });

    try {
      _krigingContourResponse = await Api.getKrigingContour(
        widget.points,
        selectedModel.toString().split('.').last,
        ModelParams(
          sill: _semivariogramaResponse!.sill!,
          range: _semivariogramaResponse!.range!,
          nugget: _semivariogramaResponse!.nugget!,
        ),
      );
      //Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mapa de contorno obtenido'),
        ),
      );
    } catch (e) {
      //Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener el mapa de contorno'),
        ),
      );
    } finally {
      setState(() {
        _isLoadingKrigingContour = false;
      });
    }
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

        FocusScope.of(context).unfocus();
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
        if (!isEditing) ..._variogramActions(),
        const SizedBox(height: 20),
        //Add title if kriging contour is not null
        if (_krigingContourResponse != null)
          const Padding(
            padding: EdgeInsets.only(
              top: 20.0,
            ),
            child: Text(
              'Mapa de contorno',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        !_isLoadingKrigingContour && _krigingContourResponse == null
            ? Container()
            : _isLoadingKrigingContour
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Base64CardImage(
                    image: _krigingContourResponse!.image_base64 ?? "",
                    title: 'Mapa de contorno',
                  ),
        if (!isEditing) ..._rowActions(),
        const SizedBox(height: 200),
      ],
    );
  }

  List<Widget> _variogramActions() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: RoundedButton(
              onPressed: () async {
                Map<String, Object>? response = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AjusteManualScreen(
                      lags: _semivariogramaResponse!.lags!,
                      semivariance: _semivariogramaResponse!.semivariance!,
                      sill: _semivariogramaResponse!.sill!,
                      range: _semivariogramaResponse!.range!,
                      nugget: _semivariogramaResponse!.nugget!,
                      model: selectedModel.toString().split('.').last,
                    ),
                  ),
                );

                if (response != null) {
                  try {
                    setState(() {
                      _isLoadingSemivariogram = true;
                      selectedModel = response['model'] as VariogramModel;
                    });

                    int nLags = int.parse(_nLagsController.text);

                    _semivariogramaResponse = await Api.getCustomSemivariogram(
                      widget.points,
                      nLags,
                      response['sill'] as double,
                      response['range'] as double,
                      response['nugget'] as double,
                      selectedModel.toString().split('.').last,
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Error al obtener el semivariograma, revise los valores del modelo'),
                      ),
                    );
                  } finally {
                    setState(() {
                      _isLoadingSemivariogram = false;
                    });
                  }
                }
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
        ],
      ),
    ];
  }

  List<Widget> _rowActions() {
    return [
      Row(
        children: [
          Expanded(
            child: RoundedButton(
              onPressed: () {
                _getKrigingContour();
              },
              icon: Icons.map,
              text: 'Mapa de contorno',
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ];
  }

  Widget _rowDetails() {
    Widget rowData = Row(
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

    if (!isEditing) {
      return rowData;
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CardDetail(
                title: "Modelo",
                value: modelToString(widget.ajuste!.model!),
                color: Colors.transparent,
                isCenter: true,
              ),
            ),
            Expanded(
              child: CardDetail(
                title: "# Lags",
                value: widget.ajuste!.nLags.toString(),
                color: Colors.transparent,
                isCenter: true,
              ),
            ),
          ],
        ),
        rowData,
      ],
    );
  }

  String modelToString(String model) {
    switch (model) {
      case 'spherical':
        return 'Esférico';
      case 'exponential':
        return 'Exponencial';
      case 'gaussian':
        return 'Gaussiano';

      case 'cubic':
        return 'Cúbico';
      default:
        return 'Esférico';
    }
  }

  void _save() async {
    TextEditingController _controller = TextEditingController();

    if (widget.nutriente != null) {
      _controller.text = "${widget.nutriente} - ${getModelName(selectedModel)}";
    } else {
      _controller.text = "${getModelName(selectedModel)}";
    }
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
        muestreoId: widget.idMuestreo,
        nombre: nombre,
        nLags: int.parse(_nLagsController.text),
        sill: _semivariogramaResponse!.sill,
        range: _semivariogramaResponse!.range,
        nugget: _semivariogramaResponse!.nugget,
        model: selectedModel.toString().split('.').last,
        semivariogramImage: _semivariogramaResponse!.image_base64,
      );

      if (_krigingContourResponse != null) {
        ajuste.contourImage = _krigingContourResponse!.image_base64;
      }

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
