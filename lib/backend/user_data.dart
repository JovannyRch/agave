import 'dart:convert';

import 'package:agave/backend/models/actividad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  static Future<void> guardarEstadoCultivo(String estado) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('estadoCultivo', estado);
  }

// Obtener el estado del cultivo
  static Future<String?> obtenerEstadoCultivo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('estadoCultivo');
  }

  // Guardar la última plaga detectada
  static Future<void> guardarUltimaPlaga(String plaga) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ultimaPlaga', plaga);
  }

// Obtener la última plaga detectada
  static Future<String?> obtenerUltimaPlaga() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ultimaPlaga');
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
}
