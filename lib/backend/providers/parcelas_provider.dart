import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ParcelasProvider extends BaseProvider {
  static final ParcelasProvider db = ParcelasProvider._();

  String table = DB.parcelas;
  ParcelasProvider._();

  Future<Parcela> insert(Parcela scan) async {
    final db = await database;

    await db!.insert(table, scan.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $table ORDER BY id DESC LIMIT 1");
    return Parcela.fromJson(res.first);
  }

  Future<List<Parcela>> getAll() async {
    final db = await database;
    final res = await db!.query(table);
    return res.isEmpty
        ? []
        : res.map((registro) => Parcela.fromJson(registro)).toList();
  }

  Future<List<Parcela>> getAllWithAgave({String? parcelasIds}) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT $table.*, agaves.nombre AS tipoAgave FROM $table INNER JOIN agaves ON $table.idTipoAgave = agaves.id ${(parcelasIds == null || parcelasIds.isEmpty) ? '' : 'WHERE $table.id IN ($parcelasIds)'}");
    return res.isEmpty
        ? []
        : res.map((registro) => Parcela.fromJson(registro)).toList();
  }

  Future<Parcela> getOneWithAgave(int id) async {
    final db = await database;
    final res = await db!.rawQuery(
        "SELECT $table.*, agaves.nombre AS tipoAgave FROM $table INNER JOIN agaves ON $table.idTipoAgave = agaves.id WHERE $table.id = $id");
    return res.isEmpty ? Parcela() : Parcela.fromJson(res.first);
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
