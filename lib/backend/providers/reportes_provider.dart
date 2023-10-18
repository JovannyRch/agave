import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/models/incidencia_plaga.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ReportesProvider extends BaseProvider {
  String tabla = DB.parcelas;
  ReportesProvider._();

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }

  Future<List<IncidenciaPlaga>> incidenciasPorPlaga(String table) async {
    final db = await database;
    List<IncidenciaPlaga> incidencias = [];

    /* Group by idPlaga from table muestreos */
    final res =
        await db!.rawQuery("SELECT idPlaga total from $table group by idPlaga");

    List<int> ids = [];

    /* Get all plaga names */
    final res2 = await db
        .rawQuery("SELECT * from ${DB.plagas} where id in (${ids.join(',')})");

    if (res.isEmpty) return [];

    return incidencias;
  }
}
