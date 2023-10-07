import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/providers/base_provider.dart';

class AgaveProvider extends BaseProvider {
  static final AgaveProvider db = AgaveProvider._();

  AgaveProvider._();

  Future<Agave> insert(Agave item) async {
    final db = await database;
    await db!.insert("agaves", item.toJson());
    final res =
        await db.rawQuery("SELECT * FROM agaves ORDER BY id DESC LIMIT 1");
    return Agave.fromJson(res.first);
  }

  Future<List<Agave>> getAll() async {
    final db = await database;
    final res = await db!.query("agaves");

    return res.isEmpty
        ? []
        : res.map((registro) => Agave.fromJson(registro)).toList();
  }

  Future<int> update(Agave item) async {
    final db = await database;
    final res = await db!
        .update("agaves", item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }
}
