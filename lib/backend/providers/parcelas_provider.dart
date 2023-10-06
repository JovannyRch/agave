import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ParcelasProvider extends BaseProvider {
  static final ParcelasProvider db = ParcelasProvider._();

  String table = DB.parcelas;
  ParcelasProvider._();

  insert(Parcela scan) async {
    final db = await database;
    return await db!.insert(table, scan.toJson());
  }

  Future<List<Parcela>> getAll() async {
    final db = await database;
    final res = await db!.query(table);
    return res.isEmpty
        ? []
        : res.map((registro) => Parcela.fromJson(registro)).toList();
  }

  Future<Parcela?> getById(int id) async {
    final db = await database;
    final res = await db!.query(table, where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? Parcela.fromJson(res.first) : null;
  }

  Future<int> update(Parcela parcela) async {
    final db = await database;
    final res = await db!.update(table, parcela.toJson(),
        where: 'id = ?', whereArgs: [parcela.id]);
    return res;
  }

  Future<int> deleteOne(int id) async {
    final db = await database;
    final res = await db!.delete(table, where: '$id = ?', whereArgs: [id]);
    return res;
  }
}
