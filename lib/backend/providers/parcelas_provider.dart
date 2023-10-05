import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ParcelasProvider extends BaseProvider {
  static final ParcelasProvider db = ParcelasProvider._();

  String tabla = DB.parcels;
  ParcelasProvider._();

  insert(Parcela scan) async {
    final db = await database;
    return await db!.insert(tabla, scan.toJson());
  }

  Future<List<Parcela>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Parcela.fromJson(registro)).toList();
  }

  Future<Parcela?> getById(int id) async {
    final db = await database;
    final res = await db!.query(tabla, where: 'idParcela = ?', whereArgs: [id]);
    return res.isNotEmpty ? Parcela.fromJson(res.first) : null;
  }

  Future<int> update(Parcela parcela) async {
    final db = await database;
    final res = await db!.update(tabla, parcela.toJson(),
        where: 'idParcela = ?', whereArgs: [parcela.id]);
    return res;
  }
}
