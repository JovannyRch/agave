class Actividad {
  String titulo;
  String fecha;
  String tipo;
  int id;

  Actividad({
    required this.titulo,
    required this.fecha,
    required this.tipo,
    required this.id,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      titulo: json['titulo'],
      fecha: json['fecha'],
      tipo: json['tipo'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'fecha': fecha,
        'tipo': tipo,
        'id': id,
      };

  @override
  String toString() {
    return 'Actividad{titulo: $titulo, fecha: $fecha, tipo: $tipo, id: $id}';
  }
}
