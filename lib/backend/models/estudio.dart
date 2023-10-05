class Estudio {
  int? idEstudio;
  int? idParcela;
  int? idPlaga;
  double? humedad;
  double? temperatura;
  String? fechaEstudio;
  String? observaciones;

  Estudio({
    this.idEstudio,
    this.idParcela,
    this.idPlaga,
    this.humedad,
    this.temperatura,
    this.fechaEstudio,
    this.observaciones,
  });

  Estudio.fromJson(Map<String, dynamic> json) {
    idEstudio = json['idEstudio'];
    idParcela = json['idParcela'];
    idPlaga = json['idPlaga'];
    humedad = json['humedad'];
    temperatura = json['temperatura'];
    fechaEstudio = json['fechaEstudio'];
    observaciones = json['observaciones'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['idEstudio'] = idEstudio;
    data['idParcela'] = idParcela;
    data['idPlaga'] = idPlaga;
    data['humedad'] = humedad;
    data['temperatura'] = temperatura;
    data['fechaEstudio'] = fechaEstudio;
    data['observaciones'] = observaciones;

    return data;
  }
}
