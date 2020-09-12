import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

import 'countries_table.dart';
import 'categories_table.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'cuentas.db'),
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE ${CountriesTable.table_name} ' +
            '(${CountriesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT, ' +
            '${CountriesTable.name} TEXT NOT NULL, ' +
            '${CountriesTable.code} TEXT, ' +
            '${CountriesTable.flag} TEXT, ' +
            '${CountriesTable.phone} TEXT' +
            ');');
        await db.execute('CREATE TABLE ${CategoriesTable.table_name} ' +
            '(${CategoriesTable.id} TEXT PRIMARY KEY, ' +
            '${CategoriesTable.name} TEXT NOT NULL, ' +
            '${CategoriesTable.icon} TEXT' +
            ');');
      },
      version: 1,
    );
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await DBHelper.database();
    return db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(
      String table, String sort) async {
    final db = await DBHelper.database();
    return db.query(table, orderBy: sort);
  }

  static Future<int> delete(String table) async {
    final db = await DBHelper.database();
    return db.delete(
      table,
    );
  }

  static Future<List<Map<String, dynamic>>> getCountry(String code) async {
    final db = await DBHelper.database();
    return db.query(
      CountriesTable.table_name,
      where: '${CountriesTable.code} = ?',
      whereArgs: [code],
    );
  }
}
