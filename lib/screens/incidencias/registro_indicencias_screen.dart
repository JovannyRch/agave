import 'package:agave/api/utmApi.dart';
import 'package:agave/backend/models/Incidencia.dart';
import 'package:agave/backend/state/StateNotifiers.dart';
import 'package:agave/backend/widgets/submit_button.dart';
import 'package:agave/utils/latLongToUTM.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class RegistroIncidenciasScreen extends StatefulWidget {
  int idMuestreo;

  RegistroIncidenciasScreen({required this.idMuestreo});

  @override
  _RegistroIncidenciasScreenState createState() =>
      _RegistroIncidenciasScreenState();
}

class _RegistroIncidenciasScreenState extends State<RegistroIncidenciasScreen> {
  final TextEditingController _incidenciasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LocationData? _currentLocation;
  final Location _location = Location();
  double? _latitude;
  double? _longitude;
  double? _norte;
  double? _este;
  String? _zona;
  IncidenciasModel? _incidenciasModel;
  bool _loading = true;
  FocusNode focus = FocusNode();

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
      final locationData = await _location.getLocation();
      UtmApiResponse? response = await latLongToUTM(
          locationData.latitude ?? 0, locationData.longitude ?? 0);

      setState(() {
        _currentLocation = locationData;

        _latitude = _currentLocation!.latitude;
        _longitude = _currentLocation!.longitude;

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
                if (!(_loading) && _currentLocation != null) ...[
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

  void _saveIncidencia() {
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

      _incidenciasModel!.add(newItem);

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
      decoration: InputDecoration(
        labelText: 'Cantidad de Incidencias',
      ),
    );
  }
}
