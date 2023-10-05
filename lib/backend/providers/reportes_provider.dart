import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/base_provider.dart';

class ReportesProvider extends BaseProvider {
  String tabla = DB.parcels;
  ReportesProvider._();

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }
}
