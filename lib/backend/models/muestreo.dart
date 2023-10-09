class Muestreo {
  int? id;
  int? idParcela;
  int? idPlaga;
  int? idEstudio;
  String? nombrePlaga;
  String? fechaCreacion;

  Muestreo(
      {this.id,
      this.idParcela,
      this.idPlaga,
      this.idEstudio,
      this.nombrePlaga,
      this.fechaCreacion});

  factory Muestreo.fromJson(Map<String, dynamic> json) => Muestreo(
        id: json["id"],
        idParcela: json["idParcela"],
        idPlaga: json["idPlaga"],
        idEstudio: json["idEstudio"],
        nombrePlaga: json["nombrePlaga"],
        fechaCreacion: json["fechaCreacion"],
      );

  Map<String, dynamic> toJson() => {
        "idParcela": idParcela,
        "idPlaga": idPlaga,
        "idEstudio": idEstudio,
      };
}
