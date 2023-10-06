class Agave {
  int? id;
  String? nombre;

  Agave({
    this.id,
    this.nombre,
  });

  factory Agave.fromJson(Map<String, dynamic> json) => Agave(
        id: json["id"],
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
      };
}
