import 'dart:math';

import 'package:agave/backend/models/Incidencia.dart';
import 'package:agave/backend/providers/incidencias_provider.dart';

class Muestreo {
  int? id;
  int? idParcela;
  int? idPlaga;
  int? idEstudio;
  String? nombrePlaga;
  String? fechaCreacion;
  double? temperatura;
  double? humedad;

  double? media;
  double? varianza;
  double? desviacionEstandar;
  int? totalMuestreos;
  List<Incidencia>? incidencias;
  int? totalIncidencias;

  Muestreo({
    this.id,
    this.idParcela,
    this.idPlaga,
    this.idEstudio,
    this.nombrePlaga,
    this.fechaCreacion,
    this.temperatura,
    this.humedad,
    this.media,
    this.varianza,
    this.desviacionEstandar,
    this.totalMuestreos,
    this.incidencias,
    this.totalIncidencias,
  });

  factory Muestreo.fromJson(Map<String, dynamic> json) => Muestreo(
        id: json["id"],
        idParcela: json["idParcela"],
        idPlaga: json["idPlaga"],
        idEstudio: json["idEstudio"],
        nombrePlaga: json["nombrePlaga"],
        fechaCreacion: json["fechaCreacion"],
        temperatura: json["temperatura"],
        humedad: json["humedad"],
      );

  Map<String, dynamic> toJson() => {
        "idParcela": idParcela,
        "idPlaga": idPlaga,
        "idEstudio": idEstudio,
        "humedad": humedad,
        "temperatura": temperatura,
      };

  Future<int> hacerCalculos() async {
    this.incidencias = await IncidenciasProvider.db.getAll(this.id!);

    if (this.incidencias!.isEmpty) {
      return 0;
    }

    this.totalIncidencias = this.incidencias!.length;
    this.totalMuestreos = 0;
    this.media = await IncidenciasProvider.db.getPromedio(this.id!);
    this.varianza = calcularVarianza(this.incidencias!, this.media!);
    this.desviacionEstandar = sqrt(this.varianza!);
    return 1;
  }

  double calcularVarianza(List<Incidencia> incidencias, double media) {
    double suma = 0;
    for (var i = 0; i < incidencias.length; i++) {
      suma += pow((incidencias[i].cantidad! - media), 2);
    }
    return suma / incidencias.length;
  }
}
