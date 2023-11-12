import 'package:agave/const.dart';
import 'package:agave/utils/models.dart';
import 'package:agave/widgets/semivariograma_widget.dart';
import 'package:flutter/material.dart';

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

  const AjusteScreen({
    super.key,
    required this.lags,
    required this.semivariance,
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
          /* Save button */
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.save),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _body,
    );
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
    return Container(
      child: Column(
        children: [
          _modelSelector(),
          _buildRange(),
          SizedBox(height: 5.0),
          _buildSill(),
          SizedBox(height: 5.0),
          _buildNugget(),
        ],
      ),
    );
  }

  Widget _modelSelector() {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              modelButton("Esférico", Model.spherical),
              modelButton("Lineal", Model.linear),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              modelButton("Gaussiano", Model.gaussian),
              modelButton("Exponencial", Model.exponential),
            ],
          ),
        ],
      ),
    );
  }

  Widget modelButton(String text, Model model) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: selectedModel == model ? kMainColor : Colors.grey,
      ),
      onPressed: () {
        setState(() {
          selectedModel = model;
          updateModelSemivariance();
        });
      },
      child: Text(text),
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
