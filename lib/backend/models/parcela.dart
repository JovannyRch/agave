class Parcela {
  int? id;
  String? nombre;
  double? superficie;
  String? fechaCreacion;
  double? latitud;
  double? longitud;
  int? idTipoAgave;
  String? estadoCultivo;
  String? observaciones;
  String? fechaUltimoMuestreo;
  String? rutaImagen;
  String? tipoAgave;

  Parcela({
    this.id,
    this.nombre,
    this.superficie,
    this.fechaCreacion,
    this.latitud,
    this.longitud,
    this.idTipoAgave,
    this.estadoCultivo,
    this.observaciones,
    this.fechaUltimoMuestreo,
    this.rutaImagen,
    this.tipoAgave,
  });

  Parcela.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    superficie = json['superficie'];
    fechaCreacion = json['fechaCreacion'];
    latitud = json['latitud'];
    longitud = json['longitud'];
    idTipoAgave = json['idTipoAgave'];
    estadoCultivo = json['estadoCultivo'];
    observaciones = json['observaciones'];
    fechaUltimoMuestreo = json['fechaUltimoMuestreo'];
    rutaImagen = json['rutaImagen'];
    tipoAgave = json['tipoAgave'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nombre'] = nombre;
    data['superficie'] = superficie;
    data['latitud'] = latitud;
    data['longitud'] = longitud;
    data['idTipoAgave'] = idTipoAgave;
    data['estadoCultivo'] = estadoCultivo;
    data['observaciones'] = observaciones;
    data['rutaImagen'] = rutaImagen;
    return data;
  }
}
