import 'package:agave/backend/models/actividad.dart';
import 'package:flutter/material.dart';

class TipoActividad {
  static String muestreo = "muestreo";
  static String incidencia = "incidencia";
}

class ActividadItem extends StatelessWidget {
  Actividad actividad;

  ActividadItem({required this.actividad});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  actividad.tipo == TipoActividad.muestreo ? "M" : "I",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.tipo == TipoActividad.muestreo
                        ? "Muestreo"
                        : "Incidencia",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    actividad.fecha ?? "",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios),
          ],
        ));
  }
}
