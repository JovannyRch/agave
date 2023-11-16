import 'dart:convert';

import 'package:agave/backend/models/actividad.dart';
import 'package:agave/backend/models/ultima_plaga.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static Future<String?> obtenerTipoCoordenadas() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tipoCoordenadas');
  }

  static Future<void> guardarTipoCoordenadas(String tipoCoordenadas) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tipoCoordenadas', tipoCoordenadas);
  }

  static Future<void> guardarEstadoCultivo(String estado) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('estadoCultivo', estado);
  }

  static Future<void> guardarUltimaPlaga(UltimaPlaga plaga) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ultimaPlaga', jsonEncode(plaga.toJson()));
  }

  static Future<UltimaPlaga?> obtenerUltimaPlaga() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonPlaga = prefs.getString('ultimaPlaga');
    if (jsonPlaga != null) {
      return UltimaPlaga.fromJson(jsonDecode(jsonPlaga));
    }
    return null;
  }

  // Guardar la actividad reciente
  static Future<void> guardarActividadReciente(
      List<Actividad> actividades) async {
    final prefs = await SharedPreferences.getInstance();

    if (actividades.length > 7) {
      actividades.removeRange(7, actividades.length);
    }

    String jsonActividades =
        jsonEncode(actividades.map((e) => e.toJson()).toList());
    prefs.setString('actividades', jsonActividades);
  }

  static Future<void> addActividad(Actividad actividad) async {
    List<Actividad> actividades = await obtenerActividadReciente();
    actividades.insert(0, actividad);
    await guardarActividadReciente(actividades);
  }

// Obtener la actividad reciente
  static Future<List<Actividad>> obtenerActividadReciente() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonActividades = prefs.getString('actividades');
    if (jsonActividades != null) {
      List<dynamic> lista = jsonDecode(jsonActividades);
      return lista.map((e) => Actividad.fromJson(e)).toList();
    }
    return [];
  }

  static void clear() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
