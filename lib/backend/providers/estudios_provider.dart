import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/providers/base_provider.dart';

class EstudiosProvider extends BaseProvider {
  static final EstudiosProvider db = EstudiosProvider._();

  String tabla = DB.estudios;

  EstudiosProvider._();

  insert(Estudio item) async {
    final db = await database;
    return await db!.insert(tabla, item.toJson());
  }

  Future<List<Estudio>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Estudio.fromJson(registro)).toList();
  }

  Future<int> update(Estudio item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }
}
