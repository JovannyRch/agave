class Actividad {
  String titulo;
  String fecha;
  String tipo;

  Actividad({
    required this.titulo,
    required this.fecha,
    required this.tipo,
  });

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      titulo: json['titulo'],
      fecha: json['fecha'],
      tipo: json['tipo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'fecha': fecha,
        'tipo': tipo,
      };
}
