import 'package:agave/api/api.dart';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/const.dart';
import 'package:agave/utils/models.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/semivariograma_widget.dart';
import 'package:agave/widgets/submit_button.dart';
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
  final List<List<double>> points;

  const AjusteScreen({
    super.key,
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
  List<double> lags = [];
  List<double> semivariance = [];
  int n_lags = 13;
  bool isLoadingSemiVariance = true;
  bool showAjusteForm = false;

  @override
  void initState() {
    super.initState();
    //Future 1 sec
    Future.delayed(Duration(milliseconds: 250), () {
      //Get semivariance
      showLagsForm();
    });
    /*  maxX = lags.reduce((value, element,) => value > element ? value : element);
    maxY = semivariance
        .reduce((value, element) => value > element ? value : element); */
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semivariograma'),
        /* actions: [
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
        ], */
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
                height: _size.height - 420,
                child: isLoadingSemiVariance
                    ? const Center(
                        child: SizedBox(
                          height: 75,
                          width: 75,
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : SemivariogramChart(
                        lags: lags,
                        semivariance: semivariance,
                        modelSemivariance: modelSemivariance,
                        range: range,
                        sill: sill,
                        nuggget: nugget,
                        maxX: maxX,
                        maxY: maxY,
                      ),
              ),
              SizedBox(height: 10.0),
              _showBodyContent(),
            ],
          ),
        ),
      );

  Widget _showBodyContent() {
    if (isLoadingSemiVariance) {
      return Container();
    }

    if (showAjusteForm) {
      return _form();
    } else {
      return _rowButtons();
    }
  }

  Widget _rowButtons() {
    return Column(
      children: [
        _row(
          RoundedButton(
            text: "Ajustar",
            color: kMainColor,
            icon: Icons.display_settings,
            onPressed: () {
              setState(() {
                showAjusteForm = !showAjusteForm;
              });
            },
          ),
          RoundedButton(
            text: "Mapa de contorno",
            color: kMainColor,
            icon: Icons.map,
            onPressed: () {
              _viewHeatMap();
            },
          ),
        ),
        const SizedBox(height: 20.0),
        _row(
          RoundedButton(
            text: "Lags",
            color: kMainColor,
            icon: Icons.settings,
            onPressed: () {
              showLagsForm();
            },
          ),
          RoundedButton(
            text: "Guardar",
            color: kMainColor,
            icon: Icons.save,
            onPressed: () {
              _viewHeatMap();
            },
          ),
        )
      ],
    );
  }

  Widget _row(Widget btn1, Widget btn2) {
    return Row(
      children: [
        Expanded(child: btn1),
        Expanded(child: btn2),
      ],
    );
  }

  void showLagsForm() {
    TextEditingController _controller = TextEditingController();
    _controller.text = n_lags.toString();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Lags"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Número de lags",
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
                fetchSemivariogram(int.parse(_controller.text));
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void fetchSemivariogram(int nLags) {
    setState(() {
      n_lags = nLags;
      isLoadingSemiVariance = true;
    });

    Api.getExperimentalSemivariogram(widget.points, nLags).then((response) {
      if (response != null) {
        setState(() {
          lags = response?.lags ?? [];
          semivariance = response?.semivariance ?? [];
          maxX = lags
              .reduce((value, element) => value > element ? value : element);
          maxY = semivariance
              .reduce((value, element) => value > element ? value : element);
          isLoadingSemiVariance = false;
          updateModelSemivariance();
        });
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener el semivariograma'),
        ),
      );
    }).whenComplete(() {
      setState(() {
        isLoadingSemiVariance = false;
      });
    });
  }

  Widget _form() {
    return Column(
      children: [
        _modelSelector(),
        _buildRange(),
        _buildSill(),
        _buildNugget(),
        //Ok button
        SubmitButton(
          text: "Ok",
          onPressed: () {
            setState(() {
              showAjusteForm = !showAjusteForm;
            });
          },
        ),
      ],
    );
  }

  Widget _modelSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
            child: Text(
              "Modelo",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownButton<Model>(
            value: selectedModel,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.black54),
            underline: Container(
              height: 1.5,
              color: kMainColor,
            ),
            onChanged: (Model? newValue) {
              setState(() {
                selectedModel = newValue!;
                updateModelSemivariance();
              });
            },
            items: Model.values.map<DropdownMenuItem<Model>>((Model value) {
              return DropdownMenuItem<Model>(
                value: value,
                child: Expanded(
                  child: Text(
                    modelToString(value),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String modelToString(Model model) {
    switch (model) {
      case Model.spherical:
        return "Esférico";
      case Model.linear:
        return "Lineal";
      case Model.gaussian:
        return "Gaussiano";
      case Model.exponential:
        return "Exponencial";
      default:
        return "Esférico";
    }
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
    return sliderInput(
      "Rango",
      range,
      0,
      maxX,
      (double value) {
        setState(() {
          range = value;
          updateModelSemivariance();
        });
      },
    );
  }

  Widget sliderInput(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          GestureDetector(
            child: SizedBox(
              width: 80,
              child: Text(
                "$label: ${value.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: () {
              TextEditingController _controller = TextEditingController();
              _controller.text = value.toStringAsFixed(0);
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(label),
                    content: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Valor",
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
                          onChanged(double.parse(_controller.text));
                        },
                        child: const Text("Guardar"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(
            width: deviceWidth - 100,
            child: Slider(
              value: value,
              min: min,
              max: max,
              label: label,
              activeColor: kMainColor,
              onChanged: (double value) {
                setState(
                  () {
                    onChanged(value);
                    updateModelSemivariance();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void updateModelSemivariance() {
    if (selectedModel == Model.spherical) {
      modelSemivariance = calculateSphericalModelSemivariance(
        lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.linear) {
      modelSemivariance = calculateLinearModelSemivariance(
        lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.gaussian) {
      modelSemivariance = calculateGaussianModelSemivariance(
        lags,
        nugget,
        sill,
        range,
      );
    } else if (selectedModel == Model.exponential) {
      modelSemivariance = calculateExponentialModelSemivariance(
        lags,
        nugget,
        sill,
        range,
      );
    }
  }

  Widget _buildSill() {
    return sliderInput(
      "Sill",
      sill,
      0,
      maxY,
      (double value) {
        setState(() {
          sill = value;
          updateModelSemivariance();
        });
      },
    );
  }

  Widget _buildNugget() {
    return sliderInput(
      "Nugget",
      nugget,
      0,
      maxY,
      (double value) {
        setState(() {
          nugget = value;
          updateModelSemivariance();
        });
      },
    );
  }
}
