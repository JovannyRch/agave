class Parcela {
  int? idParcela;
  String? nombreParcela;
  double? superficie;
  String? fechaCreacion;
  double? latitud;
  double? longitud;
  String? tipoAgave;
  String? estadoCultivo;
  String? observaciones;
  String? fechaUltimoMuestreo;
  String? rutaImagen;

  Parcela(
      {this.idParcela,
      this.nombreParcela,
      this.superficie,
      this.fechaCreacion,
      this.latitud,
      this.longitud,
      this.tipoAgave,
      this.estadoCultivo,
      this.observaciones,
      this.fechaUltimoMuestreo,
      this.rutaImagen});

  Parcela.fromJson(Map<String, dynamic> json) {
    idParcela = json['idParcela'];
    nombreParcela = json['nombreParcela'];
    superficie = json['superficie'];
    fechaCreacion = json['fechaCreacion'];
    latitud = json['latitud'];
    longitud = json['longitud'];
    tipoAgave = json['tipoAgave'];
    estadoCultivo = json['estadoCultivo'];
    observaciones = json['observaciones'];
    fechaUltimoMuestreo = json['fechaUltimoMuestreo'];
    rutaImagen = json['rutaImagen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idParcela'] = idParcela;
    data['nombreParcela'] = nombreParcela;
    data['superficie'] = superficie;
    data['fechaCreacion'] = fechaCreacion;
    data['latitud'] = latitud;
    data['longitud'] = longitud;
    data['tipoAgave'] = tipoAgave;
    data['estadoCultivo'] = estadoCultivo;
    data['observaciones'] = observaciones;
    data['fechaUltimoMuestreo'] = fechaUltimoMuestreo;
    data['rutaImagen'] = rutaImagen;
    return data;
  }
}
