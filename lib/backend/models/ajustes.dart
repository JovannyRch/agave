class Ajuste {
  int? id;
  String? nombre;
  int? muestreoId;
  String? semivariogramaExperimental;
  String? semivariogramaTeorico;
  String? lags;
  double? sill;
  double? range;
  double? nugget;
  String? modelo;
  String? imagen;

  Ajuste({
    this.id,
    this.nombre,
    this.muestreoId,
    this.semivariogramaExperimental,
    this.semivariogramaTeorico,
    this.sill,
    this.range,
    this.nugget,
    this.modelo,
    this.lags,
    this.imagen,
  });

  Ajuste.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    nombre = json['nombre'];
    muestreoId = json['muestreoId'];
    semivariogramaExperimental = json['semivariogramaExperimental'];
    semivariogramaTeorico = json['semivariogramaTeorico'];
    sill = json['sill'];
    range = json['range'];
    nugget = json['nugget'];
    modelo = json['modelo'];
    lags = json['lags'];
    imagen = json['imagen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['nombre'] = nombre;
    data['muestreoId'] = muestreoId;
    data['semivariogramaExperimental'] = semivariogramaExperimental;
    data['semivariogramaTeorico'] = semivariogramaTeorico;
    data['sill'] = sill;
    data['range'] = range;
    data['nugget'] = nugget;
    data['modelo'] = modelo;
    data['lags'] = lags;
    data['imagen'] = imagen;

    return data;
  }

  @override
  String toString() {
    return 'Ajuste{id: $id, nombre: $nombre, muestreoId: $muestreoId, semivariogramaExperimental: $semivariogramaExperimental, semivariogramaTeorico: $semivariogramaTeorico, sill: $sill, range: $range, nugget: $nugget, modelo: $modelo, lags: $lags, imagen: $imagen}';
  }
}
