import 'package:agave/api/utmApi.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/models/ubicacion.dart';
import 'package:agave/backend/models/ultima_plaga.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/const.dart';
import 'package:agave/utils/determinateLocation.dart';
import 'package:agave/widgets/RoundedButton.dart';
import 'package:agave/widgets/card_detail.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class RegistroIncidenciasScreen extends StatefulWidget {
  int idMuestreo;
  Parcela parcela;
  Muestreo muestreo;
  Incidencia? incidencia;
  Ubicacion? ubicacion;
  bool isUtm;

  RegistroIncidenciasScreen({
    required this.idMuestreo,
    required this.parcela,
    required this.muestreo,
    required this.isUtm,
    this.ubicacion,
    this.incidencia,
  });

  @override
  _RegistroIncidenciasScreenState createState() =>
      _RegistroIncidenciasScreenState();
}

class _RegistroIncidenciasScreenState extends State<RegistroIncidenciasScreen> {
  final TextEditingController _incidenciasController = TextEditingController();

  final TextEditingController _nitrogenoController = TextEditingController();
  final TextEditingController _potasioController = TextEditingController();
  final TextEditingController _fosforoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _nutrientesFormKey = GlobalKey<FormState>();

  double? _latitude;
  double? _longitude;
  double? _norte;
  double? _este;
  String? _zona;

  IncidenciasModel? _incidenciasModel;
  UbicacionesModel? _ubicacionesModel;

  bool _loading = false;
  bool isEditing = false;
  FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    isEditing = widget.incidencia != null || widget.ubicacion != null;

    setData();
  }

  void setData() async {
    if (!isEditing) {
      _getLocation();
    } else {
      if (widget.isUtm) {
        _este = widget.ubicacion != null
            ? widget.ubicacion!.x
            : widget.incidencia!.x;
        _norte = widget.ubicacion != null
            ? widget.ubicacion!.y
            : widget.incidencia!.y;
      } else {
        _latitude = widget.ubicacion != null
            ? widget.ubicacion!.y
            : widget.incidencia!.y;
        _longitude = widget.ubicacion != null
            ? widget.ubicacion!.x
            : widget.incidencia!.x;
      }

      _zona = "14Q";

      _incidenciasController.text =
          widget.incidencia != null ? widget.incidencia!.value.toString() : "0";

      if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES) {
        _nitrogenoController.text = widget.ubicacion!.nitrogeno.toString();
        _potasioController.text = widget.ubicacion!.potasio.toString();
        _fosforoController.text = widget.ubicacion!.fosforo.toString();
      }
    }
  }

  _getLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      final locationData = await determinePosition();
      updateData(
        locationData.latitude,
        locationData.longitude,
        false,
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error obteniendo ubicación: $e'),
        ),
      );
      setState(() {
        _loading = false;
      });
    }
  }

  void updateData(double latitude, double longitude, bool returnBack) async {
    _latitude = latitude;
    _longitude = longitude;

    if (widget.isUtm) {
      UtmApiResponse? response = await latLongToUTM(latitude, longitude);
      _este = response!.easting;
      _norte = response.northing;
      _zona = response.zone;
    }

    setState(() {
      _loading = false;
      if (returnBack) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _incidenciasModel = Provider.of<IncidenciasModel>(context);
    _ubicacionesModel = Provider.of<UbicacionesModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES
            ? Text("Registro de nutrientes")
            : Text("Registro de incidencia"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _loading
            ? loadingWidget("Obteniendo ubicación...")
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _mapWidget(),
                      _dataRow(),
                      if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES &&
                          isEditing)
                        _nutrientesLabels(),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RoundedButton(
                            text: "Volver a obtener ubicación",
                            onPressed: _getLocation,
                            icon: Icons.refresh,
                          ),
                          RoundedButton(
                            text: "Seleccionar ubicación",
                            onPressed: () {
                              _pickLocation(LatLng(_latitude!, _longitude!));
                            },
                            icon: Icons.location_on,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (this.widget.muestreo.tipo == Muestreo.TIPO_PLAGA)
                        _cantidadIncidenciasInput(),
                      if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES &&
                          isEditing)
                        _nutrientesForm(),
                      if (isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SubmitButton(
                              onPressed: () {
                                _showDeleteConfirmationDialog(context);
                              },
                              text: widget.muestreo.tipo ==
                                      Muestreo.TIPO_NUTRIENTES
                                  ? "Eliminar registro"
                                  : "Eliminar",
                            ),
                            SubmitButton(
                              onPressed: _updateIncidencia,
                              text: "Guardar cambios",
                            ),
                          ],
                        ),
                      if (!isEditing)
                        SubmitButton(
                          onPressed: _saveIncidencia,
                          text: "Registrar ubicación",
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _nutrientesLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _card(
            "Nitrógeno", _nitrogenoStatus(widget.ubicacion!.nitrogeno ?? 0.0)),
        _card("Potasio", _potasionStatus(widget.ubicacion!.potasio ?? 0.0)),
        _card("Fósforo", _fosforoStatus(widget.ubicacion!.fosforo ?? 0.0)),
      ],
    );
  }

  //Input for potassium, phosphorus and nitrogen
  Widget _nutrientesForm() {
    return Form(
      key: _nutrientesFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nitrogenoController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la cantidad de nitrógeno';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Nitrógeno',
            ),
          ),
          TextFormField(
            controller: _potasioController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la cantidad de potasio';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Potasio',
            ),
          ),
          TextFormField(
            controller: _fosforoController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la cantidad de fósforo';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Fósforo',
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    String title = widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES
        ? "Eliminar registro"
        : "Eliminar incidencia";

    String content = widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES
        ? "¿Está seguro que desea eliminar este registro?"
        : "¿Está seguro que desea eliminar esta incidencia?";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES) {
                  await _ubicacionesModel!.delete(widget.ubicacion!.id!);
                } else {
                  await _incidenciasModel!.delete(widget.incidencia!.id!);
                }

                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }

  void _updateUbicacion() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Ubicacion newItem = Ubicacion();
      newItem.id = widget.ubicacion!.id;
      newItem.idMuestreo = widget.idMuestreo;
      newItem.x = _este;
      newItem.y = _norte;
      newItem.nitrogeno = double.parse(_nitrogenoController.text);
      newItem.potasio = double.parse(_potasioController.text);
      newItem.fosforo = double.parse(_fosforoController.text);

      _ubicacionesModel!.update(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ubicación actualizada!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  void _updateIncidencia() async {
    if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES) {
      _updateUbicacion();
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Incidencia newItem = Incidencia();

      newItem.id = widget.incidencia!.id;
      newItem.value = double.parse(_incidenciasController.text);
      newItem.idMuestreo = widget.idMuestreo;

      if (widget.isUtm) {
        newItem.y = _norte;
        newItem.x = _este;
      } else {
        newItem.y = _latitude;
        newItem.x = _longitude;
      }

      await _incidenciasModel!.update(newItem);

      UltimaPlaga ultimaPlaga = UltimaPlaga(
        nombre: widget.muestreo.nombrePlaga ?? "",
        fecha: DateTime.now().toIso8601String(),
        parcela: widget.parcela.nombre ?? "",
        idMuestreo: widget.muestreo.id ?? -1,
      );

      UserData.guardarUltimaPlaga(ultimaPlaga);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidencia actualizada!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _dataRow() {
    return Row(
      children: widget.isUtm
          ? [
              _card("Norte", _norte.toString()),
              _card("Este", _este.toString()),
              _card("Zona", _zona.toString()),
            ]
          : [
              _card("Latitud", _latitude.toString()),
              _card("Longitud", _longitude.toString()),
            ],
    );
  }

  Widget _card(String title, String value) {
    return Expanded(
      child: CardDetail(
        title: title,
        value: value,
        isCenter: true,
        color: Colors.transparent,
      ),
    );
  }

  Widget _mapWidget() {
    if (_latitude == null && _longitude == null) {
      return Container();
      /* return Container(
        height: 250,
        child: Center(
          child: Text(
            "No se pudo mostrar la ubicación en el mapa.",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ); */
    }

    return Container(
      height: 250,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_latitude!, _longitude!),
          zoom: 18,
        ),
        markers: {
          Marker(
            markerId: MarkerId('1'),
            position: LatLng(_latitude!, _longitude!),
          ),
        },
        onTap: (LatLng position) {
          _pickLocation(position);
        },
      ),
    );
  }

  Widget loadingWidget(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: LinearProgressIndicator(),
          ),
        ],
      ),
    );
  }

  void _pickLocation(LatLng initialPosition) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: MAP_KEY,
          onPlacePicked: (result) async {
            try {
              setState(() {
                _loading = true;
              });
              updateData(
                result.geometry!.location.lat,
                result.geometry!.location.lng,
                true,
              );
            } catch (e) {
              setState(() {
                _loading = false;
              });
            }
          },
          initialPosition: initialPosition,
          desiredLocationAccuracy: LocationAccuracy.best,
          /*  initialMapType: MapType.satellite, */
          useCurrentLocation: true,
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }

  void _saveLocation() async {
    Ubicacion ubicacion = Ubicacion();

    ubicacion.x = widget.isUtm ? _este : _longitude;
    ubicacion.y = widget.isUtm ? _norte : _latitude;
    ubicacion.idMuestreo = widget.idMuestreo;
    ubicacion.fosforo = 0.0;
    ubicacion.potasio = 0.0;
    ubicacion.nitrogeno = 0.0;

    await _ubicacionesModel!.add(ubicacion);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ubicación registrada!',
        ),
      ),
    );

    Navigator.pop(context);
  }

  void _saveIncidencia() async {
    if (widget.muestreo.tipo == Muestreo.TIPO_NUTRIENTES) {
      _saveLocation();

      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Incidencia newItem = Incidencia();

      newItem.value = double.parse(_incidenciasController.text);
      newItem.idMuestreo = widget.idMuestreo;

      if (widget.isUtm) {
        newItem.x = _este;
        newItem.y = _norte;
      } else {
        newItem.x = _longitude;
        newItem.y = _latitude;
      }

      await _incidenciasModel!.add(newItem);

      UltimaPlaga ultimaPlaga = UltimaPlaga(
        nombre: widget.muestreo.nombrePlaga ?? "",
        fecha: DateTime.now().toIso8601String(),
        parcela: widget.parcela.nombre ?? "",
        idMuestreo: widget.muestreo.id ?? -1,
      );

      UserData.guardarUltimaPlaga(ultimaPlaga);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incidencia registrada!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _cantidadIncidenciasInput() {
    return TextFormField(
      focusNode: focus,
      controller: _incidenciasController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese la cantidad de incidencias';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Cantidad de Incidencias',
      ),
    );
  }

  String _nitrogenoStatus(double value) {
    if (value < 0.05) {
      return "Muy bajo";
    } else if (value >= 0.05 && value < 0.10) {
      return "Bajo";
    } else if (value >= 0.10 && value < 0.15) {
      return "Medio";
    } else if (value >= 0.15 && value <= 0.25) {
      return "Alto";
    } else {
      return "Muy alto";
    }
  }

  String _fosforoStatus(double value) {
    if (value < 15) {
      return "Bajo";
    } else if (value >= 15 && value < 30) {
      return "Medio";
    } else {
      return "Muy alto";
    }
  }

  String _potasionStatus(double value) {
    if (value < 150) {
      return "Bajo";
    } else if (value >= 150 && value < 250) {
      return "Medio";
    } else if (value >= 250 && value < 800) {
      return "Alto";
    } else {
      return "Muy alto";
    }
  }
}
