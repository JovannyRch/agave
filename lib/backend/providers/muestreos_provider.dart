import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/muestreo.dart';
import 'package:agave/backend/providers/base_provider.dart';

class MuestreosProvider extends BaseProvider {
  static final MuestreosProvider db = MuestreosProvider._();

  String tabla = DB.muestreos;

  MuestreosProvider._();

  Future<Muestreo> insert(Muestreo item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");
    return Muestreo.fromJson(res.first);
  }

  Future<List<Muestreo>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Muestreo.fromJson(registro)).toList();
  }

  Future<int> update(Muestreo item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }

  Future<List<Muestreo>> getAllWithPlagas(int idEstudio, int idParcela) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT $tabla.*, plagas.nombre AS nombrePlaga FROM $tabla INNER JOIN plagas ON $tabla.idPlaga = plagas.id WHERE $tabla.idEstudio = $idEstudio AND $tabla.idParcela = $idParcela and $tabla.tipo = ${Muestreo.TIPO_PLAGA}");
    return res.isEmpty
        ? []
        : res.map((registro) => Muestreo.fromJson(registro)).toList();
  }

  Future<List<Muestreo>> getAllNutrientesTipo(
      int idEstudio, int idParcela) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT $tabla.* FROM $tabla WHERE $tabla.idEstudio = $idEstudio AND $tabla.idParcela = $idParcela and $tabla.tipo = ${Muestreo.TIPO_NUTRIENTES}");
    return res.isEmpty
        ? []
        : res.map((registro) => Muestreo.fromJson(registro)).toList();
  }

  Future<Muestreo?> getOneWithPlaga(int idMuestreo) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT $tabla.*, plagas.nombre AS nombrePlaga FROM $tabla INNER JOIN plagas ON $tabla.idPlaga = plagas.id WHERE $tabla.id = $idMuestreo");
    return res.isEmpty ? null : Muestreo.fromJson(res.first);
  }
}
