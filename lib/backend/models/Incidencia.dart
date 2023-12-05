class Incidencia {
  int? id;
  int? idMuestreo;
  double? x;
  double? y;
  double? value;

  Incidencia({
    this.id,
    this.idMuestreo,
    this.x,
    this.y,
    this.value,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) => Incidencia(
        id: json["id"],
        idMuestreo: json["idMuestreo"],
        x: json["x"],
        y: json["y"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "idMuestreo": idMuestreo,
        "x": x,
        "y": y,
        "value": value,
      };

  factory Incidencia.fromCsv(int idMuestreo, List<dynamic> row) {
    return Incidencia(
      idMuestreo: idMuestreo,
      x: double.parse(row[0].toString()),
      y: double.parse(row[1].toString()),
      value: double.parse(row[2].toString()),
    );
  }
}

List<Incidencia> parseIncidencias(int idMuestreo, List<List<dynamic>> csvData) {
  return csvData.map((row) => Incidencia.fromCsv(idMuestreo, row)).toList();
}
