import 'dart:math';

import 'package:agave/backend/models/incidencia.dart';

class CalculoResultado {
  double media;
  double varianza;
  double desviacionEstandar;
  int totalMuestreos;
  int totalIncidencias;

  CalculoResultado({
    required this.media,
    required this.varianza,
    required this.desviacionEstandar,
    required this.totalMuestreos,
    required this.totalIncidencias,
  });
}

class Calculo {
  List<Incidencia> incidencias;

  Calculo({required this.incidencias});

  Future<CalculoResultado> calcular() async {
    double media = 0;
    double varianza = 0;
    double desviacionEstandar = 0;
    int totalMuestreos = incidencias.length;
    int totalIncidencias = 0;

    for (var i = 0; i < incidencias.length; i++) {
      totalIncidencias += incidencias[i].cantidad?.toInt() ?? 0;
    }

    media = totalIncidencias / totalMuestreos;

    varianza = calcularVarianza(media);
    desviacionEstandar = sqrt(varianza);

    return CalculoResultado(
      media: media,
      varianza: varianza,
      desviacionEstandar: desviacionEstandar,
      totalMuestreos: totalMuestreos,
      totalIncidencias: totalIncidencias,
    );
  }

  double calcularVarianza(double media) {
    double suma = 0;
    for (var i = 0; i < incidencias.length; i++) {
      suma += pow((incidencias[i].cantidad! - media), 2);
    }
    return suma / incidencias.length;
  }
}
