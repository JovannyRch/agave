import 'dart:io';
import 'package:agave/backend/models/database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class BaseProvider {
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, '$kDBname.db');
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      List<String> tablas = kTables;
      for (String tabla in tablas) {
        await db.execute(tabla);
      }
    });
  }

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  Future<int> delete(String id, String table, String field) async {
    final db = await database;
    final res = await db!.delete(table, where: '$field = ?', whereArgs: [id]);
    return res;
  }

  Future<int> deleteAll(String table) async {
    final db = await database;
    final res = await db!.rawDelete("DELETE from $table");
    return res;
  }

  Future<int> getTotal(String table) async {
    final db = await database;
    final res = await db!.rawQuery("SELECT count(*) total from $table");
    return res.first['total'] == null
        ? 0
        : int.parse(res.first['total'].toString());
  }
}
