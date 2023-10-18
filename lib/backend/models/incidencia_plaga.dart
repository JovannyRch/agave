class IncidenciaPlaga {
  String plaga;
  int cantidad;

  IncidenciaPlaga({
    required this.plaga,
    required this.cantidad,
  });

  factory IncidenciaPlaga.fromJson(Map<String, dynamic> json) {
    return IncidenciaPlaga(
      plaga: json['plaga'],
      cantidad: json['cantidad'],
    );
  }
}
