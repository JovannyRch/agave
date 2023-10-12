class Incidencia {
  int? id;
  int? idMuestreo;
  int? cantidad;
  double? latitud;
  double? longitud;
  double? norte;
  double? este;
  String? zona;

  Incidencia({
    this.id,
    this.idMuestreo,
    this.cantidad,
    this.latitud,
    this.longitud,
    this.norte,
    this.este,
    this.zona,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) => Incidencia(
        id: json["id"],
        idMuestreo: json["idMuestreo"],
        cantidad: json["cantidad"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        norte: json["norte"],
        este: json["este"],
        zona: json["zona"],
      );

  Map<String, dynamic> toJson() => {
        "idMuestreo": idMuestreo,
        "cantidad": cantidad,
        "latitud": latitud,
        "longitud": longitud,
        "norte": norte,
        "este": este,
        "zona": zona,
      };
}
