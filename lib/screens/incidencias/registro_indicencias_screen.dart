import 'package:agave/api/utmApi.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
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

  RegistroIncidenciasScreen({
    required this.idMuestreo,
    required this.parcela,
    required this.muestreo,
    this.incidencia,
  });

  @override
  _RegistroIncidenciasScreenState createState() =>
      _RegistroIncidenciasScreenState();
}

class _RegistroIncidenciasScreenState extends State<RegistroIncidenciasScreen> {
  final TextEditingController _incidenciasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double? _latitude;
  double? _longitude;
  double? _norte;
  double? _este;
  String? _zona;

  IncidenciasModel? _incidenciasModel;
  MuestreosModel? _muestreosModel;
  bool _loading = false;
  bool isUTM = false;
  bool isEditing = false;
  FocusNode focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadData();
    isEditing = widget.incidencia != null;

    if (!isEditing) {
      _getLocation();
    } else {
      _latitude = widget.incidencia!.latitud;
      _longitude = widget.incidencia!.longitud;
      _norte = widget.incidencia!.norte;
      _este = widget.incidencia!.este;
      _zona = widget.incidencia!.zona;
      _incidenciasController.text = widget.incidencia!.cantidad.toString();
    }
  }

  _loadData() async {
    isUTM = await UserData.isUtm();
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
      print('Error obteniendo ubicación: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void updateData(double latitude, double longitude, bool returnBack) async {
    UtmApiResponse? response = await latLongToUTM(latitude, longitude);

    setState(() {
      _latitude = latitude;
      _longitude = longitude;
      _este = response!.easting;
      _norte = response.northing;
      _zona = response.zone;
      _loading = false;
      /*  focus.requestFocus(); */
      if (returnBack) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _incidenciasModel = Provider.of<IncidenciasModel>(context);
    _muestreosModel = Provider.of<MuestreosModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Incidencia'),
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
                      _cantidadIncidenciasInput(),
                      SizedBox(height: 20),
                      if (!isEditing)
                        SubmitButton(
                          onPressed: _saveIncidencia,
                          text: "Registrar",
                        ),
                      if (isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SubmitButton(
                              onPressed: () {
                                _showDeleteConfirmationDialog(context);
                              },
                              text: "Eliminar",
                            ),
                            SubmitButton(
                              onPressed: _updateIncidencia,
                              text: "Actualizar",
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Eliminar incidencia"),
          content: Text("¿Está seguro que desea eliminar esta incidencia?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await _incidenciasModel!.delete(widget.incidencia!.id!);
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

  void _updateIncidencia() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Incidencia newItem = Incidencia();

      newItem.id = widget.incidencia!.id;
      newItem.cantidad = int.parse(_incidenciasController.text);
      newItem.latitud = _latitude!;
      newItem.longitud = _longitude!;
      newItem.idMuestreo = widget.idMuestreo;
      newItem.este = _este;
      newItem.norte = _norte;

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
      children: isUTM
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
    if (_latitude == null || _longitude == null) {
      return Container(
        height: 250,
        child: Center(
          child: Text(
            "No se pudo obtener la ubicación",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
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
              print('Error obteniendo ubicación: $e');
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

  void _saveIncidencia() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Incidencia newItem = Incidencia();

      newItem.cantidad = int.parse(_incidenciasController.text);
      newItem.latitud = _latitude!;
      newItem.longitud = _longitude!;
      newItem.idMuestreo = widget.idMuestreo;
      newItem.este = _este;
      newItem.norte = _norte;

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
}
