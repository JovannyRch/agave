import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/incidencia_plaga.dart';
import 'package:agave/backend/models/reporteConteo.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ReportesProvider extends BaseProvider {
  static final ReportesProvider db = ReportesProvider._();

  ReportesProvider._();

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }

  Future<List<IncidenciaPlaga>> incidenciasPorPlaga() async {
    final db = await database;
    List<IncidenciaPlaga> resultado = [];

    final res = await db!.rawQuery("SELECT id,nombre from ${DB.plagas}");

    if (res.isEmpty) return [];

    resultado = res
        .map(
          (e) => IncidenciaPlaga(
            cantidad: 0,
            id: int.parse(e['id'].toString()),
            plaga: e['nombre'].toString(),
          ),
        )
        .toList();

    for (var inicidencia in resultado) {
      final res = await db.rawQuery(
          "SELECT id from ${DB.muestreos} where idPlaga = ${inicidencia.id}");

      if (res.isEmpty) continue;

      List<int> muestreosIds =
          res.map((e) => int.parse(e['id'].toString())).toList();
      final res2 = await db.rawQuery(
          "SELECT sum(value) value from ${DB.incidencias} where id in (${muestreosIds.join(',')}) ");

      double cantidad = res2.first['value'] == null
          ? 0
          : double.parse(res2.first['value'].toString());

      inicidencia.cantidad = cantidad;
    }

    resultado = resultado.where((element) => element.cantidad != 0).toList();

    return resultado;
  }

  Future<ReporteConteo> reporteConteo() async {
    final db = await database;
    ReporteConteo resultado = ReporteConteo();

    //Get total of estudios
    final res = await db!.rawQuery("SELECT count(*) total from ${DB.estudios}");
    resultado.estudios = res.first['total'] == null
        ? 0
        : int.parse(res.first['total'].toString());

    //Get total of parcelas
    final res2 = await db.rawQuery("SELECT count(*) total from ${DB.parcelas}");
    resultado.parcelas = res2.first['total'] == null
        ? 0
        : int.parse(res2.first['total'].toString());

    //Get total of muestreos
    final res3 =
        await db.rawQuery("SELECT count(*) total from ${DB.muestreos}");
    resultado.muestreos = res3.first['total'] == null
        ? 0
        : int.parse(res3.first['total'].toString());

    return resultado;
  }
}
