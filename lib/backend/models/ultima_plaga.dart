class UltimaPlaga {
  String nombre;
  String fecha;
  String parcela;
  int idMuestreo;

  UltimaPlaga({
    required this.nombre,
    required this.fecha,
    required this.parcela,
    required this.idMuestreo,
  });

  factory UltimaPlaga.fromJson(Map<String, dynamic> json) {
    return UltimaPlaga(
      nombre: json['nombre'],
      fecha: json['fecha'],
      parcela: json['parcela'],
      idMuestreo: json['idMuestreo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'fecha': fecha,
        'parcela': parcela,
        'idMuestreo': idMuestreo,
      };

  @override
  String toString() {
    return 'UltimaPlaga{nombre: $nombre, fecha: $fecha, parcela: $parcela, idMuestreo: $idMuestreo}';
  }
}
