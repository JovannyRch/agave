import 'package:agave/backend/models/ajustes.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/base_provider.dart';

class AjustesProvider extends BaseProvider {
  static final AjustesProvider db = AjustesProvider._();
  String tabla = DB.ajustes;

  AjustesProvider._();

  Future<Ajuste> insert(Ajuste item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");

    return Ajuste.fromJson(res.first);
  }

  Future<List<Ajuste>> getAll(int idMuestreo) async {
    final db = await database;
    final res = await db!
        .query(tabla, where: 'muestreoId = ?', whereArgs: [idMuestreo]);
    return res.isEmpty
        ? []
        : res.map((registro) => Ajuste.fromJson(registro)).toList();
  }

  Future<int> update(Ajuste item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }
}
