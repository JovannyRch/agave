import 'package:agave/backend/models/agave.dart';
import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/base_provider.dart';

class AgaveProvider extends BaseProvider {
  static final AgaveProvider db = AgaveProvider._();

  String tabla = DB.plagas;
  AgaveProvider._();

  insert(Agave item) async {
    final db = await database;
    return await db!.insert(tabla, item.toJson());
  }

  Future<List<Agave>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    print(res);
    return res.isEmpty
        ? []
        : res.map((registro) => Agave.fromJson(registro)).toList();
  }
}
