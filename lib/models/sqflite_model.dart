// ignore_for_file: prefer_const_declarations

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todo_model.dart';

class DatabaseConnect {
  static final DatabaseConnect instance = DatabaseConnect._initialize();
  static Database? _database;
  DatabaseConnect._initialize();

  Future<Database> _initDB(String fileName) async {
    final dbpath = await getDatabasesPath(); //Location of our db in device
    final path = join(dbpath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future close() async {
    final db = await instance.database;
    db!.close();
  }

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await _initDB('todo.db');
      return _database;
    }
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreing_keys = ON');
  }

  //Creates tables in our DB
  Future _createDB(Database db, int version) async {
    final userUsernameType = 'TEXT PRIMARY KEY NOT NULL';
    final textType = 'TEXT NOT NULL';
    final intType = 'INTEGER NOT NULL';

    await db.execute(
        '''
    CREATE TABLE $todoTable(
      ${TodoFields.id} $textType,
      ${TodoFields.username} $textType,
      ${TodoFields.title} $textType,
      ${TodoFields.creationDate} $textType,
      ${TodoFields.isChecked} $intType
    )
    ''');

    await db.execute(
        ''' CREATE TABLE $userTable(
      ${UserFields.username} $userUsernameType,
      ${UserFields.name} $textType
      )
''');
  }

  Future<Users> createUser(Users users) async {
    final db = await instance.database;
    await db!.insert(userTable, users.toJson());
    return users;
  }

  Future<Users> getUser(String username) async {
    final db = await instance.database;
    final maps = await db!.query(userTable,
        columns: UserFields.allFields,
        where: '${UserFields.username} = ?',
        whereArgs: [username]);
    if (maps.isNotEmpty) {
      return Users.fromJson(maps.first);
    } else {
      throw Exception('$username not found in the database');
    }
  }

  Future<List<Users>> getAllUser(String username) async {
    final db = await instance.database;
    final result = await db!.query(
      userTable,
      orderBy: '${UserFields.username} ASC',
    );
    return result.map((e) => Users.fromJson(e)).toList();
  }

  Future<int> updateUser(Users users) async {
    final db = await instance.database;
    return db!.update(userTable, users.toJson(),
        where: '${UserFields.username} = ?', whereArgs: [users.username]);
  }

  Future<int> deleteUser(String username) async {
    final db = await instance.database;
    return db!.delete(userTable,
        where: '${UserFields.username} = ?', whereArgs: [username]);
  }

  Future<Todo> createTodo(Todo todo) async {
    final db = await instance.database; //Connection DB
    await db!.insert(
      todoTable,
      todo.toJson(),
    );
    return todo;
  }

  Future<int> toggleTodoDone(Todo todo) async {
    final db = await instance.database;
    todo.isChecked = !todo.isChecked;
    return db!.update(todoTable, todo.toJson(),
        where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
        whereArgs: [todo.title, todo.username]);
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await instance.database;
    return db!.update(todoTable, todo.toJson(),
        where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
        whereArgs: [todo.title, todo.username]);
  }

  Future<int> deleteTodo(Todo todo) async {
    final db = await instance.database;
    return await db!.delete(
      todoTable,
      where: '${TodoFields.title} = ? AND ${TodoFields.username} = ?',
      whereArgs: [todo.title, todo.username],
    );
  }

  Future<List<Todo>> getTodos(String username) async {
    final db = await instance.database;
    final result = await db!.query(
      todoTable,
      orderBy: '${TodoFields.creationDate} DESC',
      where: '${TodoFields.username} = ?',
      whereArgs: [username],
    );
    return result.map((e) => Todo.fromJson(e)).toList();
  }

  Future<int> deleteAllTodos() async {
    final db = await instance.database;
    return await db!.delete(todoTable);
  }
}
