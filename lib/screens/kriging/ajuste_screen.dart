import 'package:agave/api/api.dart';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/const.dart';
import 'package:agave/utils/models.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/semivariograma_widget.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

/* const lags = [
  21.015123121183937,
  49.28636841525929,
  80.24371511799016,
  111.74996243123789,
  141.47585829622963,
  168.88347164191998
];

const semivariance = [
  487.3976927747419,
  632.2879310344828,
  815.5228984633926,
  1187.9924069855733,
  933.7788868723533,
  949.4097472924187
]; */

class AjusteScreen extends StatefulWidget {
  final List<double> lags;
  final List<double> semivariance;
  final List<List<double>> points;

  const AjusteScreen({
    super.key,
    required this.lags,
    required this.semivariance,
    required this.points,
  });

  @override
  State<AjusteScreen> createState() => _AjusteScreenState();
}

//Models enum
enum Model { spherical, linear, gaussian, exponential }

class _AjusteScreenState extends State<AjusteScreen> {
  late Size _size;
  double maxX = 0;
  double maxY = 0;
  double sill = 0;
  double range = 0;
  double nugget = 0;
  List<double> modelSemivariance = [];
  Model selectedModel = Model.spherical;
  Api api = Api();
  bool isLoadingHeatMap = false;

  @override
  void initState() {
    super.initState();
    maxX = widget.lags
        .reduce((value, element) => value > element ? value : element);
    maxY = widget.semivariance
        .reduce((value, element) => value > element ? value : element);
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste'),
        actions: [
          /*  IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
          ), */
          IconButton(
            onPressed: (isLoadingHeatMap || modelSemivariance.isEmpty)
                ? null
                : _viewHeatMap,
            icon: const Icon(Icons.map),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _body,
    );
  }

  void _viewHeatMap() async {
    setState(() {
      isLoadingHeatMap = true;
    });
    try {
      KrigingContourResponse? krigingContourResponse =
          await Api.getKrigingContour(
        widget.points,
        selectedModel.toString().split('.').last,
        ModelParams(
          sill: sill,
          range: range,
          nugget: nugget,
        ),
      );

      if (krigingContourResponse != null) {
        String imageBase64 = krigingContourResponse.image_base64 ?? "";
        final imageProvider = Image.memory(
          fit: BoxFit.cover,
          Base64Decoder().convert(
            imageBase64,
          ),
        ).image;
        showImageViewer(context, imageProvider, onViewerDismissed: () {
          print("dismissed");
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el mapa de contorno'),
        ),
      );
    } finally {
      setState(() {
        isLoadingHeatMap = false;
      });
    }
  }

  void _save() {
    //Open a dialog to enter the name of the model
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar modelo"),
          content: TextField(
            decoration: const InputDecoration(
              labelText: "Nombre del modelo",
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
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  Widget get _body => Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: _size.height * 0.5,
                child: SemivariogramChart(
                  lags: widget.lags,
                  semivariance: widget.semivariance,
                  modelSemivariance: modelSemivariance,
                  range: range,
                  sill: sill,
                  nuggget: nugget,
                  maxX: maxX,
                  maxY: maxY,
                ),
              ),
              _form()
            ],
          ),
        ),
      );

  Widget _form() {
    return Column(
      children: [
        _modelSelector(),
        SizedBox(height: 15.0),
        _buildRange(),
        SizedBox(height: 5.0),
        _buildSill(),
        SizedBox(height: 5.0),
        _buildNugget(),
      ],
    );
  }

  Widget _modelSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text(
          "Modelo",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            modelButton("Esférico", Model.spherical),
            modelButton("Lineal", Model.linear),
            modelButton("Gaussiano", Model.gaussian),
            modelButton("Exponencial", Model.exponential),
          ],
        ),
      ],
    );
  }

  Widget modelButton(String text, Model model) {
    return RoundedButton(
      text: text,
      color: selectedModel == model ? kMainColor : Colors.black54,
      onPressed: () {
        setState(() {
          selectedModel = model;
          updateModelSemivariance();
        });
      },
      icon: selectedModel == model ? Icons.check : null,
    );
  }

  Widget _buildRange() {
    return Container(
      child: Column(
        children: [
          Text("Rango: ${range.toStringAsFixed(0)}"),
          Slider(
            value: range,
            min: 0,
            max: 200,
            label: 'Rango',
            activeColor: kMainColor,
            onChanged: (double value) {
              setState(
                () {
                  range = value;
                  updateModelSemivariance();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void updateModelSemivariance() {
    if (selectedModel == Model.spherical) {
      modelSemivariance = calculateSphericalModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.linear) {
      modelSemivariance = calculateLinearModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.gaussian) {
      modelSemivariance = calculateGaussianModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.exponential) {
      modelSemivariance = calculateExponentialModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    }
  }

  Widget _buildSill() {
    return Container(
      child: Column(
        children: [
          Text("Meseta: ${sill.toStringAsFixed(0)}"),
          Slider(
            value: sill,
            min: 0,
            max: maxY,
            label: 'Meseta',
            activeColor: kMainColor,
            onChanged: (double value) {
              setState(() {
                sill = value;
                updateModelSemivariance();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNugget() {
    return Container(
      child: Column(
        children: [
          Text("Efecto pepita ${nugget.toStringAsFixed(0)}"),
          Slider(
            value: nugget,
            min: 0,
            max: maxY,
            label: 'Efecto pepita',
            activeColor: kMainColor,
            onChanged: (double value) {
              setState(() {
                nugget = value;
                updateModelSemivariance();
              });
            },
          ),
        ],
      ),
    );
  }
}
