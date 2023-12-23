class Ubicacion {
  int? id;
  int? idMuestreo;
  double? x;
  double? y;
  double? nitrogeno;
  double? fosforo;
  double? potasio;

  Ubicacion({
    this.id,
    this.idMuestreo,
    this.x,
    this.y,
    this.nitrogeno,
    this.fosforo,
    this.potasio,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) => Ubicacion(
        id: json["id"],
        idMuestreo: json["idMuestreo"],
        x: json["x"],
        y: json["y"],
        nitrogeno: json["nitrogeno"],
        fosforo: json["fosforo"],
        potasio: json["potasio"],
      );

  Map<String, dynamic> toJson() => {
        "idMuestreo": idMuestreo,
        "x": x,
        "y": y,
        "nitrogeno": nitrogeno,
        "fosforo": fosforo,
        "potasio": potasio,
      };

  factory Ubicacion.fromCsv(int idMuestreo, List<dynamic> row) {
    return Ubicacion(
      idMuestreo: idMuestreo,
      x: double.parse(row[0].toString()),
      y: double.parse(row[1].toString()),
      nitrogeno: double.parse(row[2].toString()),
      fosforo: double.parse(row[3].toString()),
      potasio: double.parse(row[4].toString()),
    );
  }
}

List<Ubicacion> parseUbicacion(int idMuestreo, List<List<dynamic>> csvData) {
  return csvData.map((row) => Ubicacion.fromCsv(idMuestreo, row)).toList();
}
