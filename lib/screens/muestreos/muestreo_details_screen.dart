import 'package:agave/api/api.dart';
import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
import 'package:agave/screens/genera/image_loader.dart';
import 'package:agave/screens/kriging/ajuste_screen.dart';
import 'package:agave/screens/kriging/new_ajuste_screen.dart';
import 'package:agave/utils/exportIncidencias.dart';
import 'package:agave/utils/formatDate.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/calculos_bottom_sheet.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/screen_title.dart';
import 'package:agave/screens/incidencias/registro_indicencias_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MuestreoDetailsScreen extends StatefulWidget {
  Muestreo muestreo;
  Parcela parcela;
  Estudio estudio;

  MuestreoDetailsScreen({
    required this.muestreo,
    required this.parcela,
    required this.estudio,
  });

  @override
  State<MuestreoDetailsScreen> createState() => _MuestreoDetailsScreenState();
}

class _MuestreoDetailsScreenState extends State<MuestreoDetailsScreen> {
  IncidenciasModel? _model;
  AjustesModel? _ajustesModel;

  bool isLoading = false;
  late Size size;
  bool isUTM = false;
  bool hasIncidencias = false;

  List<List<double>> points = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    Provider.of<IncidenciasModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);
    String tipoCoordenadas = await UserData.obtenerTipoCoordenadas() ?? "UTM";
    if (tipoCoordenadas == "UTM") {
      isUTM = true;
    }

    Provider.of<AjustesModel>(context, listen: false)
        .fetchData(widget.muestreo.id ?? -1);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    _model = Provider.of<IncidenciasModel>(context);

    hasIncidencias = _model?.incidencias.isNotEmpty ?? false;
    _ajustesModel = Provider.of<AjustesModel>(context);

    return Scaffold(
      appBar: _appBar(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroIncidenciasScreen(
                idMuestreo: widget.muestreo.id ?? -1,
                muestreo: widget.muestreo,
                parcela: widget.parcela,
                isUtm: isUTM,
              ),
            ),
          );
        },
        tooltip: 'Agregar Incidencia',
        child: const Icon(Icons.pin_drop),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SizedBox(
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScreenTitle(
                subtitle: "Plaga",
                title: widget.muestreo.nombrePlaga ?? "",
              ),
              _grid(),
              hasIncidencias ? const Divider() : Container(),
              scrollableActionRowList(),
              const Divider(),
              const SizedBox(
                height: 30.0,
              ),
              const Text(
                "Registros",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              ..._incidenciasList(),
              const SizedBox(height: 80.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rowDetails(Widget child1, Widget child2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: child1),
        Expanded(child: child2),
      ],
    );
  }

  List<Widget> _incidenciasList() {
    if (!hasIncidencias) {
      return [
        const SizedBox(
          height: 150.0,
          child: Center(
            child: Text('No hay registros'),
          ),
        ),
      ];
    }

    return _model!.incidencias.map((incidencia) {
      return ListTile(
        leading: const Icon(
          Icons.location_on,
          color: kMainColor,
        ),
        title: Text(
          _getCoordenadas(incidencia),
          style: const TextStyle(
            fontSize: 11.0,
          ),
        ),
        subtitle: Text(
          'Incidencia: ${incidencia.value}',
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistroIncidenciasScreen(
                idMuestreo: widget.muestreo.id ?? -1,
                muestreo: widget.muestreo,
                parcela: widget.parcela,
                incidencia: incidencia,
                isUtm: isUTM,
              ),
            ),
          );
        },
      );
    }).toList();
  }

  String _getCoordenadas(Incidencia incidencia) {
    if (isUTM) {
      return 'E: ${incidencia.x}, N: ${incidencia.y}';
    } else {
      return 'Lng: ${incidencia.x}, Ltd: ${incidencia.y}';
    }
  }

  Widget scrollableActionRowList() {
    int total = _model?.incidencias.length ?? 0;
    if (total == 0) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RoundedButton(
                  text: 'Gráfico de dispersión',
                  icon: Icons.map,
                  onPressed: () {
                    List<List<double>> points = _model?.incidencias
                            .map((e) => [e.x!, e.y!, e.value!.toDouble()])
                            .toList() ??
                        [];

                    if (points.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No hay registros'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageLoaderScreen(
                          title: "Gráfico de dispersión",
                          loadImage: () async {
                            String? response = await Api.getScatterPlot(
                              points,
                            );
                            return response;
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: RoundedButton(
                  text: 'Nuevo ajuste',
                  onPressed: isLoading ? null : _iniciarAjuste,
                  icon: Icons.line_axis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RoundedButton(
                  icon: Icons.percent,
                  text: 'Cálculos',
                  onPressed: _openCalculosBottomSheet,
                ),
              ),
              Expanded(
                child: RoundedButton(
                  icon: Icons.list_alt,
                  text: 'Ajustes guardados',
                  onPressed: _openListAjustesDialog,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openListAjustesDialog() {
    List<Ajuste> _ajustesModelList = _ajustesModel?.ajustes ?? [];
    List<List<double>> points = _model?.incidencias
            .map((e) => [e.x!, e.y!, e.value!.toDouble()])
            .toList() ??
        [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajustes guardados'),
          content: Container(
            width: size.width * 0.8,
            height: size.height * 0.5,
            child: _ajustesModelList.isEmpty
                ? const Text('No hay ajustes')
                : ListView.builder(
                    itemCount: _ajustesModelList.length,
                    itemBuilder: (context, index) {
                      Ajuste ajuste = _ajustesModelList[index];
                      return ListTile(
                        title: Text(ajuste.nombre ?? ""),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewAjusteScreen(
                                points: [],
                                idMuestreo: widget.muestreo.id ?? -1,
                                ajuste: ajuste,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _openCalculosBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return CalculosBottomSheet(
          incidencias: _model?.incidencias ?? [],
        );
      },
    );
  }

  Widget _grid() {
    bool hasHumedad = widget.muestreo.humedad != null;
    bool hasTemperatura = widget.muestreo.temperatura != null;
    return Column(
      children: [
        _rowDetails(
          CardDetail(
            color: Colors.transparent,
            title: "Estudio",
            value: widget.estudio.nombre ?? "",
            icon: Icons.folder,
          ),
          CardDetail(
            title: "Parcela",
            value: widget.parcela.nombre ?? "",
            color: Colors.transparent,
            icon: Icons.nature,
          ),
        ),
        _rowDetails(
          CardDetail(
            title: "Creación",
            value: formatDate(widget.muestreo.fechaCreacion),
            color: Colors.transparent,
            icon: Icons.calendar_today,
          ),
          CardDetail(
            title: "Registros",
            value: _model!.incidencias.length.toString(),
            color: Colors.transparent,
            icon: Icons.list,
          ),
        ),
        (hasHumedad || hasTemperatura)
            ? _rowDetails(
                hasHumedad
                    ? CardDetail(
                        title: "Humedad",
                        value: widget.muestreo.humedad.toString(),
                        unit: "%",
                        color: Colors.transparent,
                        icon: Icons.water,
                      )
                    : Container(),
                hasTemperatura
                    ? CardDetail(
                        title: "Temperatura",
                        value: widget.muestreo.temperatura.toString(),
                        unit: "°C",
                        color: Colors.transparent,
                        icon: Icons.thermostat,
                      )
                    : Container(),
              )
            : Container(),
      ],
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text('Muestreo'),
      actions: [
        PopupMenuButton<String>(
          onSelected: handleClick,
          itemBuilder: (BuildContext context) {
            return {'Importar', 'Exportar', 'Eliminar registros'}
                .map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        )
      ],
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Exportar':
        _compartir();
        break;
      case 'Importar':
        _importar();
        break;
      case 'Eliminar registros':
        _eliminarRegistros();
        break;
    }
  }

  void _eliminarRegistros() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar registros'),
          content: const Text('¿Está seguro de eliminar todos los registros?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _model?.deleteAllIncidencias(_model?.incidencias ?? []);
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _compartir() {
    String defaultFileName = "${(widget.muestreo.nombrePlaga ?? "muestreo")}_" +
        "${formatDate(widget.muestreo.fechaCreacion)}";
    TextEditingController _controller = TextEditingController(
      text: defaultFileName.replaceAll(" ", "_"),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exportar datos'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Nombre del archivo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String csvContent = convertirIncidenciasACsv(
                  _model?.incidencias ?? [],
                );
                bool response = await guardarCsv(
                  csvContent,
                  _controller.text,
                );

                if (response) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Archivo guardado'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'No se pudo guardar el archivo, revise los permisos de almacenamiento en su dispositivo'),
                    ),
                  );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _importar() async {
    try {
      FilePickerResult? result = await pickCsvFile();

      if (result != null) {
        String csvContent = await readCsvFileFromPath(result);

        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Importando datos'),
              content: LinearProgressIndicator(),
            );
          },
        );

        List<Incidencia> incidencias = await parseIncidencias(
          widget.muestreo.id!,
          await loadCsvData(csvContent),
        );

        int total = incidencias.length;

        incidencias.forEach((element) async {
          await _model?.add(element);
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se importaron $total registros'),
          ),
        );
      }
    } catch (e) {
      print(e);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrío un error al importar el archivo'),
        ),
      );
    }
  }

  void _iniciarAjuste() async {
    List<Incidencia> incidencias = _model?.incidencias ?? [];

    if (incidencias.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Se necesitan al menos 3 registros para realizar el ajuste'),
        ),
      );
      return;
    }

    List<List<double>> points =
        incidencias.map((e) => [e.x!, e.y!, e.value!.toDouble()]).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewAjusteScreen(
          points: points,
          idMuestreo: widget.muestreo.id ?? -1,
        ),
      ),
    );
  }
}
