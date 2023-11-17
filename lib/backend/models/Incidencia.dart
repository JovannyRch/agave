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

  factory Incidencia.fromCsv(int idMuestreo, List<dynamic> row) {
    return Incidencia(
      idMuestreo: idMuestreo,
      latitud: row[0],
      longitud: row[1],
      norte: row[2],
      este: row[3],
      zona: row[4],
      cantidad: row[5],
    );
  }
}

List<Incidencia> parseIncidencias(int idMuestreo, List<List<dynamic>> csvData) {
  return csvData.map((row) => Incidencia.fromCsv(idMuestreo, row)).toList();
}
