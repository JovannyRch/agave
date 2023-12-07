class Ajuste {
  int? id;
  String? nombre;
  int? muestreoId;
  int? nLags;
  double? sill;
  double? range;
  double? nugget;
  String? model;
  String? semivariogramImage;
  String? contourImage;

  Ajuste({
    this.id,
    this.nombre,
    this.muestreoId,
    this.nLags,
    this.sill,
    this.range,
    this.nugget,
    this.model,
    this.semivariogramImage,
    this.contourImage,
  });

  Ajuste.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    nombre = json['nombre'];
    muestreoId = json['muestreoId'];
    sill = json['sill'];
    range = json['range'];
    nugget = json['nugget'];
    model = json['model'];
    semivariogramImage = json['semivariogramImage'];
    contourImage = json['contourImage'];
    nLags = json['nLags'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['nombre'] = nombre;
    data['muestreoId'] = muestreoId;
    data['sill'] = sill;
    data['range'] = range;
    data['nugget'] = nugget;
    data['model'] = model;
    data['semivariogramImage'] = semivariogramImage;
    data['contourImage'] = contourImage;
    data['nLags'] = nLags;

    return data;
  }

  @override
  String toString() {
    return 'Ajuste{id: $id, nombre: $nombre, muestreoId: $muestreoId, sill: $sill, range: $range, nugget: $nugget, model: $model, semivariogramImage: $semivariogramImage, contourImage: $contourImage}';
  }
}
