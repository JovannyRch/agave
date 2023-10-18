import 'package:agave/api/utmApi.dart';
import 'package:agave/backend/models/incidencia.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/models/ultima_plaga.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/user_data.dart';
import 'package:agave/widgets/submit_button.dart';
import 'package:agave/utils/latLongToUTM.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class RegistroIncidenciasScreen extends StatefulWidget {
  int idMuestreo;
  Parcela parcela;
  Muestreo muestreo;

  RegistroIncidenciasScreen({
    required this.idMuestreo,
    required this.parcela,
    required this.muestreo,
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
  bool _loading = true;
  FocusNode focus = FocusNode();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  _getLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      final locationData = await _determinePosition();
      UtmApiResponse? response = await latLongToUTM(
          locationData.latitude ?? 0, locationData.longitude ?? 0);

      setState(() {
        _latitude = locationData.latitude;
        _longitude = locationData.longitude;

        _este = response!.easting;
        _norte = response.northing;
        _zona = response.zone;
        focus.requestFocus();
      });
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _incidenciasModel = Provider.of<IncidenciasModel>(context);
    _muestreosModel = Provider.of<MuestreosModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Incidencias'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (_loading) CircularProgressIndicator(),
                if (!_loading) ...[
                  TextFormField(
                    initialValue: '${_norte}',
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Norte'),
                  ),
                  TextFormField(
                    initialValue: '${_este}',
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Este'),
                  ),
                  TextFormField(
                    initialValue: '${_zona}',
                    readOnly: true,
                    decoration: InputDecoration(labelText: 'Zona'),
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loading ? null : _getLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Volver a obtener ubicación',
                  ),
                ),
                SizedBox(height: 20),
                _cantidadIncidenciasInput(),
                SizedBox(height: 20),
                SubmitButton(
                  text: "Registrar",
                  onPressed: _saveIncidencia,
                )
              ],
            ),
          ),
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

      UtmResult result = latLonToUtm(_latitude!, _longitude!);

      newItem.norte = result.easting;
      newItem.este = result.northing;
      newItem.zona = result.zone;

      await _incidenciasModel!.add(newItem);
      _muestreosModel!.selectedMuestreo!.hacerCalculos();

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
