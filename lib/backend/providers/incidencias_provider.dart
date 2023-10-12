import 'package:agave/backend/models/Incidencia.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/base_provider.dart';

class IncidenciasProvider extends BaseProvider {
  static final IncidenciasProvider db = IncidenciasProvider._();

  String tabla = DB.incidencias;

  IncidenciasProvider._();

  Future<Incidencia> insert(Incidencia item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");
    return Incidencia.fromJson(res.first);
  }

  Future<List<Incidencia>> getAll(int idMuestreo) async {
    final db = await database;
    final res = await db!
        .query(tabla, where: 'idMuestreo = ?', whereArgs: [idMuestreo]);
    return res.isEmpty
        ? []
        : res.map((registro) => Incidencia.fromJson(registro)).toList();
  }
}
