class Plaga {
  int? id;
  String? nombre;

  Plaga({
    this.id,
    this.nombre,
  });

  factory Plaga.fromJson(Map<String, dynamic> json) => Plaga(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
