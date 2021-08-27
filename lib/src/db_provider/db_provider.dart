import 'dart:io';

import 'package:offline_maps_app/src/model_data.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {

  static  Database? _dataBase;
  static final DBProvider db = DBProvider._();
  DBProvider._();

  Future<Database> get database async{
    if(_dataBase != null) return _dataBase!;  

    _dataBase = await initDB();

    return _dataBase!;
  
  }

  Future<Database>initDB()async{
    
    // Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'demo.db');
    await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version)async{
        await db.execute(
        'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
      }
    );
  }

  newCommitRaw( String commit ,int id   )async{
    DataCommit commitData = DataCommit(
      id: id,
      commit: commit,
    );
    final db = await database;
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO Test(name, value, num) VALUES("$commit", 1234, 456.789)');
      print('inserted1: $id1');
    });
  }

}