import 'package:agave/api/api.dart';
import 'package:agave/api/responses/kriging_contour_response.dart';
import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/const.dart';
import 'package:agave/utils/models.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/semivariograma_widget.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

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
  final int idMuestreo;
  final Ajuste? ajuste;

  const AjusteScreen({
    super.key,
    required this.points,
    required this.idMuestreo,
    this.ajuste,
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
  int n_lags = 10;
  bool isLoadingSemiVariance = true;
  bool showAjusteForm = false;
  int currentTab = 0;

  AjustesModel? _ajustesModel;

  @override
  void initState() {
    super.initState();
    //Future 1 sec
    Future.delayed(Duration(milliseconds: 250), () {
      //Get semivariance
      if (widget.ajuste == null) {
        showLagsForm();
      }
    });

    if (widget.ajuste != null) {
      sill = widget.ajuste!.sill ?? 0;
      range = widget.ajuste!.range ?? 0;
      nugget = widget.ajuste!.nugget ?? 0;
      selectedModel = modelFromString(widget.ajuste!.modelo ?? "");
      modelSemivariance =
          doubleValuesFromJson(widget.ajuste!.semivariogramaTeorico ?? "");
      lags = doubleValuesFromJson(widget.ajuste!.lags ?? "");
      semivariance =
          doubleValuesFromJson(widget.ajuste!.semivariogramaExperimental ?? "");
      maxX = lags.reduce((value, element) => value > element ? value : element);
      maxY = semivariance
          .reduce((value, element) => value > element ? value : element);
      isLoadingSemiVariance = false;
      updateModelSemivariance();
    }
  }

  List<double> doubleValuesFromJson(String json) {
    List<dynamic> values = jsonDecode(json);
    return values.map((e) => double.parse(e.toString())).toList();
  }

  Model modelFromString(String model) {
    switch (model) {
      case "spherical":
        return Model.spherical;
      case "linear":
        return Model.linear;
      case "gaussian":
        return Model.gaussian;
      case "exponential":
        return Model.exponential;
      default:
        return Model.spherical;
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;
    _ajustesModel = Provider.of<AjustesModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semivariograma'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _body,
    );
  }

  Future<String?> base64Image() async {
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
      return krigingContourResponse.image_base64 ?? "";
    }
    return null;
  }

  void _viewHeatMap() async {
    setState(() {
      isLoadingHeatMap = true;
    });
    try {
      String? imageBase64 = await base64Image();

      if (imageBase64 != null) {
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
    TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Guardar ajuste"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Nombre del ajuste",
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
      String? imageBase64 = await base64Image();
      Ajuste ajuste = Ajuste(
        modelo: selectedModel.toString().split('.').last,
        sill: sill,
        range: range,
        nugget: nugget,
        semivariogramaExperimental: jsonEncode(semivariance),
        semivariogramaTeorico: jsonEncode(modelSemivariance),
        lags: jsonEncode(lags),
        muestreoId: widget.idMuestreo,
        nombre: nombre,
        imagen: imageBase64,
      );
      _ajustesModel!.add(ajuste);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajuste guardado'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el ajuste'),
        ),
      );
    }
  }

  Widget get _body => Container(
        child: SingleChildScrollView(
          child: Column(children: [
            _tabs(),
            ...currentTab == 0 ? chartContent() : tableContent(),
          ]),
        ),
      );

  Widget _tabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          tabWidget(
            () {
              setState(() {
                currentTab = 0;
              });
            },
            "Gráfica",
            currentTab == 0 ? kMainColor : Colors.white,
            currentTab == 0 ? Colors.white : Colors.black,
          ),
          const SizedBox(width: 5.0),
          tabWidget(
            () {
              setState(() {
                currentTab = 1;
              });
            },
            "Tabla",
            currentTab == 1 ? kMainColor : Colors.white,
            currentTab == 1 ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }

  List<Widget> tableContent() {
    return [
      //Table of semivariance values
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
        child: Table(
          border: TableBorder.all(
            color: Colors.black,
            width: 1,
          ),
          children: [
            const TableRow(
              children: [
                TableCell(
                  child: SizedBox(
                    height: 25.0,
                    child: Center(
                      child: Text(
                        "Lag",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                TableCell(
                  child: SizedBox(
                    height: 25.0,
                    child: Center(
                      child: Text(
                        "Semivarianza",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ...List.generate(
              lags.length,
              (index) => TableRow(
                children: [
                  tableCellClickable(lags, index),
                  tableCellClickable(semivariance, index),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  TableCell tableCellClickable(List<double> data, int index) {
    return TableCell(
      child: GestureDetector(
        onTap: () {
          TextEditingController _controller = TextEditingController();
          _controller.text = data[index].toStringAsFixed(2);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Editar"),
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
                      setState(() {
                        data[index] = double.parse(_controller.text);
                        updateModelSemivariance();
                      });
                    },
                    child: const Text("Guardar"),
                  ),
                ],
              );
            },
          );
        },
        child: SizedBox(
          height: 25.0,
          child: Center(
            child: Text(
              data[index].toStringAsFixed(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget tabWidget(
      Function() onPressed, String text, Color color, Color textColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: kMainColor,
              width: 0.5,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> chartContent() {
    return [
      SizedBox(
        height: _size.height - 430,
        child: isLoadingSemiVariance
            ? const Center(
                child: SizedBox(
                  height: 75,
                  width: 75,
                  child: CircularProgressIndicator(),
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
      isLoadingSemiVariance ? Container() : _chartLegend(),
      const SizedBox(height: 20.0),
      ..._showBodyContent()
    ];
  }

  Widget _chartLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      width: _size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                color: Colors.red,
              ),
              const SizedBox(width: 5.0),
              const Text(
                "S. Experimental",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10.0),
          Row(
            children: [
              Container(
                height: 10,
                width: 10,
                color: kMainColor,
              ),
              const SizedBox(width: 5.0),
              const Text(
                "S. Teórico",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _showBodyContent() {
    if (isLoadingSemiVariance) {
      return [Container()];
    }

    if (widget.ajuste != null) {
      return [
        Row(
          children: [
            Expanded(
              child: CardDetail(
                title: "Meseta",
                value: widget.ajuste!.sill.toString(),
                color: Colors.transparent,
                isCenter: true,
              ),
            ),
            Expanded(
              child: CardDetail(
                title: "Rango",
                value: widget.ajuste!.range.toString(),
                color: Colors.transparent,
                isCenter: true,
              ),
            ),
            Expanded(
              child: CardDetail(
                title: "E. Pepita",
                value: widget.ajuste!.nugget.toString(),
                color: Colors.transparent,
                isCenter: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RoundedButton(
              text: "Mapa de contornos",
              color: kMainColor,
              icon: Icons.map,
              onPressed: () {
                _viewHeatMap();
              },
            ),
          ],
        ),
      ];
    }

    if (showAjusteForm) {
      return _form();
    }
    return _rowButtons();
  }

  List<Widget> _rowButtons() {
    return [
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
          text: "Mapa de contornos",
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
            _save();
          },
        ),
      )
    ];
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
            keyboardType: TextInputType.number,
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
              child: const Text("Ok"),
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

  List<Widget> _form() {
    return [
      _modelSelector(),
      _buildRange(),
      _buildSill(),
      _buildNugget(),
      //Ok button
      SubmitButton(
        text: "Ok",
        mt: 0,
        onPressed: () {
          setState(() {
            showAjusteForm = !showAjusteForm;
          });
        },
      ),
      const SizedBox(height: 20.0),
    ];
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
