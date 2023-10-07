import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/base_provider.dart';

class PlagasProvider extends BaseProvider {
  static final PlagasProvider db = PlagasProvider._();

  String tabla = DB.plagas;
  PlagasProvider._();

  Future<Plaga> insert(Plaga item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");
    return Plaga.fromJson(res.first);
  }

  Future<List<Plaga>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Plaga.fromJson(registro)).toList();
  }

  Future<int> update(Plaga item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }
}
