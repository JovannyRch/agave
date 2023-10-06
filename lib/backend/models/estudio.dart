class Estudio {
  int? id;
  String? nombre;
  String? fechaCreacion;
  String? observaciones;

  Estudio({
    this.id,
    this.nombre,
    this.fechaCreacion,
    this.observaciones,
  });

  Estudio.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    nombre = json['nombre'];
    fechaCreacion = json['fechaCreacion'];
    observaciones = json['observaciones'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['nombre'] = nombre;
    data['fechaCreacion'] = fechaCreacion;
    data['observaciones'] = observaciones;

    return data;
  }
}
