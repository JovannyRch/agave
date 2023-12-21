import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/estudio.dart';
import 'package:agave/backend/models/parcela.dart';
import 'package:agave/backend/providers/base_provider.dart';
import 'package:agave/backend/providers/parcelas_provider.dart';

class EstudiosProvider extends BaseProvider {
  static final EstudiosProvider db = EstudiosProvider._();

  String tabla = DB.estudios;

  EstudiosProvider._();

  Future<Estudio> insert(Estudio item) async {
    final db = await database;
    await db!.insert(tabla, item.toJson());

    final res =
        await db.rawQuery("SELECT * FROM $tabla ORDER BY id DESC LIMIT 1");
    return Estudio.fromJson(res.first);
  }

  Future<List<Estudio>> getAll() async {
    final db = await database;
    final res = await db!.query(tabla);
    return res.isEmpty
        ? []
        : res.map((registro) => Estudio.fromJson(registro)).toList();
  }

  Future<Estudio> getById(int id) async {
    final db = await database;
    final res = await db!.query(tabla, where: 'id = ?', whereArgs: [id]);
    return Estudio.fromJson(res.first);
  }

  Future<int> update(Estudio item) async {
    final db = await database;
    final res = await db!
        .update(tabla, item.toJson(), where: 'id = ?', whereArgs: [item.id]);
    return res;
  }

  Future<Parcela?> joinParcela(int idEstudio, int idParcela) async {
    final db = await database;

    final res = await db!.rawQuery(
        "SELECT * FROM estudios_parcelas WHERE idEstudio = $idEstudio AND idParcela = $idParcela");

    if (res.isNotEmpty) {
      return null;
    }

    await db!.insert("estudios_parcelas", {
      "idEstudio": idEstudio,
      "idParcela": idParcela,
    });

    final res2 = await db.rawQuery(
        "SELECT * FROM parcelas WHERE id = $idParcela ORDER BY id DESC LIMIT 1");
    return Parcela.fromJson(res2.first);
  }

  Future<List<Parcela>> getParcelas(int idEstudio) async {
    final db = await database;
    final parcelas = await db!.rawQuery(
        "SELECT * FROM estudios_parcelas WHERE idEstudio = $idEstudio");

    if (parcelas.isEmpty) return [];

    return ParcelasProvider.db.getAllWithAgave(
        parcelasIds:
            parcelas.map((e) => e['idParcela'].toString()).join(',') ?? '');
  }
}
