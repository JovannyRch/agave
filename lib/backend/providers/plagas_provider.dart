import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/plaga.dart';
import 'package:agave/backend/providers/base_provider.dart';

class PlagasProvider extends BaseProvider {
  static final PlagasProvider db = PlagasProvider._();

  String tabla = DB.plagues;
  PlagasProvider._();

  insert(Plaga item) async {
    final db = await database;
    return await db!.insert(tabla, item.toJson());
  }

  Future<List<Plaga>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    print(res);
    return res.isEmpty
        ? []
        : res.map((registro) => Plaga.fromJson(registro)).toList();
  }
}
