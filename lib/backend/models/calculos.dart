import 'dart:math';

class CalculoResultado {
  double media;
  double varianza;
  double desviacionEstandar;
  int totalMuestreos;
  double totalIncidencias;

  CalculoResultado({
    required this.media,
    required this.varianza,
    required this.desviacionEstandar,
    required this.totalMuestreos,
    required this.totalIncidencias,
  });
}

class Calculo {
  List<double> values;

  Calculo({required this.values});

  Future<CalculoResultado> calcular() async {
    double media = 0;
    double varianza = 0;
    double desviacionEstandar = 0;
    int totalMuestreos = values.length;
    double totalIncidencias = 0.0;

    for (var i = 0; i < values.length; i++) {
      totalIncidencias += values[i].toDouble() ?? 0.0;
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
    for (var i = 0; i < values.length; i++) {
      suma += pow((values[i]! - media), 2);
    }
    return suma / values.length;
  }
}
