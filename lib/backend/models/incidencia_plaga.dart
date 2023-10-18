class IncidenciaPlaga {
  String plaga;
  int cantidad;
  int id;

  IncidenciaPlaga({
    required this.plaga,
    required this.cantidad,
    required this.id,
  });

  factory IncidenciaPlaga.fromJson(Map<String, dynamic> json) {
    return IncidenciaPlaga(
      plaga: json['plaga'],
      cantidad: json['cantidad'],
      id: json['id'],
    );
  }

  @override
  String toString() {
    return 'IncidenciaPlaga{plaga: $plaga, cantidad: $cantidad, id: $id}';
  }
}
