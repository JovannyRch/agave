class Muestreo {
  int? id;
  int? idParcela;
  int? idPlaga;
  int? idEstudio;
  String? nombrePlaga;
  String? fechaCreacion;
  double? temperatura;
  double? humedad;

  Muestreo({
    this.id,
    this.idParcela,
    this.idPlaga,
    this.idEstudio,
    this.nombrePlaga,
    this.fechaCreacion,
    this.temperatura,
    this.humedad,
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
}
