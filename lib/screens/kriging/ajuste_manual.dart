import 'package:agave/const.dart';
import 'package:agave/utils/models.dart';
import 'package:agave/widgets/semivariograma_widget.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';

class AjusteManualScreen extends StatefulWidget {
  final List<double> lags;
  final List<double> semivariance;
  final double sill;
  final double range;
  final double nugget;
  final String model;

  const AjusteManualScreen({
    Key? key,
    required this.lags,
    required this.semivariance,
    required this.sill,
    required this.range,
    required this.nugget,
    required this.model,
  }) : super(key: key);
  @override
  State<AjusteManualScreen> createState() => _AjusteManulScreaenState();
}

class _AjusteManulScreaenState extends State<AjusteManualScreen> {
  double maxY = 0.0;
  double maxX = 0.0;
  VariogramModel selectedModel = VariogramModel.spherical;
  List<double> modelSemivariance = [];

  double nugget = 0.0;
  double sill = 0.0;
  double range = 0.0;

  TextEditingController nuggetController = TextEditingController();
  TextEditingController sillController = TextEditingController();
  TextEditingController rangeController = TextEditingController();

  VariogramModel _getVariogramModel(String model) {
    if (model == 'spherical') {
      return VariogramModel.spherical;
    } else if (model == 'gaussian') {
      return VariogramModel.gaussian;
    } else if (model == 'exponential') {
      return VariogramModel.exponential;
    } else {
      return VariogramModel.spherical;
    }
  }

  @override
  void initState() {
    nugget = widget.nugget;
    sill = widget.sill;
    range = widget.range;

    maxX = widget.lags
        .reduce((value, element) => value > element ? value : element);
    maxY = widget.semivariance
        .reduce((value, element) => value > element ? value : element);
    selectedModel = _getVariogramModel(widget.model);

    //Set initial values for the controllers
    nuggetController.text = widget.nugget.toString();
    sillController.text = widget.sill.toString();
    rangeController.text = widget.range.toString();

    updateModelSemivariance();
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuste Manual'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _modelInput(),
            SizedBox(
              height: _size.height - 430,
              child: _buildSemivariogram(),
            ),
            _valueInputs(),
            SubmitButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'nugget': nugget,
                    'sill': sill,
                    'range': range,
                    'model': selectedModel,
                  },
                );
              },
              text: 'Guardar',
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _modelInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            width: 55.0,
            child: Text('Modelo'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButton<VariogramModel>(
              value: selectedModel,
              onChanged: (VariogramModel? value) {
                if (value != null) {
                  selectedModel = value;
                  updateModelSemivariance();
                  setState(() {});
                }
              },
              items: VariogramModel.values
                  .map<DropdownMenuItem<VariogramModel>>(
                    (VariogramModel value) => DropdownMenuItem<VariogramModel>(
                      value: value,
                      child: Text(
                        getModelName(value),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildSemivariogram() {
    return SemivariogramChart(
      lags: widget.lags,
      semivariance: widget.semivariance,
      modelSemivariance: modelSemivariance,
      sill: sill,
      range: range,
      nuggget: nugget,
      maxX: maxX,
      maxY: maxY,
    );
  }

  void updateModelSemivariance() {
    if (selectedModel == VariogramModel.spherical) {
      modelSemivariance = calculateSphericalModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == VariogramModel.gaussian) {
      modelSemivariance = calculateGaussianModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == VariogramModel.exponential) {
      modelSemivariance = calculateExponentialModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == VariogramModel.cubic) {
      modelSemivariance = calculateCubicModelSemivariance(
        widget.lags,
        nugget,
        sill,
        range,
      );
    }
  }

  Widget _valueInputs() {
    return Column(
      children: [
        inputWithOptionalSlider(
          'E. Pepita',
          nugget,
          maxY,
          0,
          (value) {
            nugget = value;
            nuggetController.text = value.toString();
            updateModelSemivariance();
          },
          nuggetController,
        ),
        inputWithOptionalSlider(
          'Meseta',
          sill,
          maxY,
          0,
          (value) {
            sill = value;
            sillController.text = value.toString();
            updateModelSemivariance();
          },
          sillController,
        ),
        inputWithOptionalSlider(
          'Rango',
          range,
          maxX,
          0,
          (value) {
            range = value;
            rangeController.text = value.toString();
            updateModelSemivariance();
          },
          rangeController,
        ),
      ],
    );
  }

  Widget inputWithOptionalSlider(
      String label,
      double value,
      double max,
      double min,
      Function(double) onChanged,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 55.0,
                child: Text(label),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    suffixIcon: Icon(Icons.edit),
                  ),
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    onChanged(double.parse(value));
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
          Slider(
            value: value,
            max: max,
            min: min,
            thumbColor: kMainColor,
            activeColor: kMainColor,
            inactiveColor: kMainColor.withOpacity(0.3),
            onChanged: (value) {
              onChanged(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
