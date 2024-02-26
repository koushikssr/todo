import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_tasks.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      startDate TEXT,
      endDate TEXT,
      description TEXT,
      userEmail TEXT
    )
  ''');
    await db.execute(
        'CREATE TABLE User(id INTEGER PRIMARY KEY, email TEXT, password TEXT)');

    await db.execute('''
          CREATE TABLE shared_tasks (
             id INTEGER PRIMARY KEY AUTOINCREMENT,
             name TEXT,
             startDate TEXT,
             endDate TEXT,
             description TEXT,
             userEmail TEXT
          )
        ''');





  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    Database db = await instance.database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> retrieveTasks(String userEmail) async {
    Database db = await instance.database;
    return await db.query('tasks', where: 'userEmail = ?', whereArgs: [userEmail]);
  }



  Future<int> updateTask(Map<String, dynamic> task) async {
    Database db = await instance.database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveUser(Map<String, dynamic> user) async {
    var dbClient = await database;
    return await dbClient.insert('User', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    var dbClient = await database;
    return await dbClient.query('User');
  }

  // Future<void> shareTask(int taskId, String email) async {
    Future<int> shareTask(Map<String, dynamic> task) async {

      final db = await database;
    return await db.insert('shared_tasks', task);

    // await db.insert('shared_tasks', {
    //   'taskId': taskId,
    //   'email': email,
    // });
  }

  Future<int> shareUpdateTask(Map<String, dynamic> task) async {

    Database db = await instance.database;
    return await db.update('shared_tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<List<Map<String, dynamic>>> retrieveReceivedTasks(String userEmail) async {
    Database db = await instance.database;
    return await db.query('shared_tasks', where: 'userEmail = ?', whereArgs: [userEmail]);
  }
  Future<Map<String, dynamic>> retrieveSharedTask(int taskId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('shared_tasks', where: 'taskId = ?', whereArgs: [taskId]);
    return result.isNotEmpty ? result.first : null;
  }


}
