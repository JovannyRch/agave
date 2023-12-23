import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/ubicacion.dart';
import 'package:agave/backend/providers/base_provider.dart';

class UbicacionesProvider extends BaseProvider {
  static final UbicacionesProvider db = UbicacionesProvider._();

  String tabla = DB.ubicaciones;

  UbicacionesProvider._();

  Future<Ubicacion> insert(Ubicacion item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");
    return Ubicacion.fromJson(res.first);
  }

  Future<List<Ubicacion>> getAll(int idMuestreo) async {
    final db = await database;
    final res = await db!
        .query(tabla, where: 'idMuestreo = ?', whereArgs: [idMuestreo]);
    return res.isEmpty
        ? []
        : res.map((registro) => Ubicacion.fromJson(registro)).toList();
  }

  Future<int> update(Ubicacion item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }

  //insertMany
  Future<void> insertMany(List<Ubicacion> ubicaciones) async {
    final db = await database;

    for (var item in ubicaciones) {
      await db!.insert(tabla, item.toJson());
    }
  }
}
