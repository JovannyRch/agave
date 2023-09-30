import 'package:agave/backend/models/database.dart';
import 'package:agave/backend/providers/base_provider.dart';
import 'package:sqflite/sqflite.dart';

class ReportesProvider extends BaseProvider {
  static Database? _database;
  static final ReportesProvider db = ReportesProvider._();

  String tabla = DB.parcels;
  ReportesProvider._();

  @override
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  Future<int> total(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");

    if (res.isEmpty) return 0;
    return int.parse(res.first['total'].toString());
  }
}
