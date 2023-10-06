class Estudio {
  int? id;
  int? idParcela;
  int? idPlaga;
  double? humedad;
  double? temperatura;
  String? fechaEstudio;
  String? observaciones;
  String? nombrePlaga;

  Estudio({
    this.id,
    this.idParcela,
    this.idPlaga,
    this.humedad,
    this.temperatura,
    this.fechaEstudio,
    this.observaciones,
    this.nombrePlaga,
  });

  Estudio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idParcela = json['idParcela'];
    idPlaga = json['idPlaga'];
    humedad = json['humedad'];
    temperatura = json['temperatura'];
    fechaEstudio = json['fechaEstudio'];
    observaciones = json['observaciones'];
    nombrePlaga = json['nombrePlaga'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['idParcela'] = idParcela;
    data['idPlaga'] = idPlaga;
    data['humedad'] = humedad;
    data['temperatura'] = temperatura;
    data['fechaEstudio'] = fechaEstudio;
    data['observaciones'] = observaciones;

    return data;
  }
}
