import 'package:flutter/cupertino.dart';
import 'package:sqflite_todo/models/sqflite_model.dart';
import 'package:sqflite_todo/models/todo_model.dart';

class TodoService with ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  Future<String> getTodos(String username) async {
    try {
      _todos = await DatabaseConnect.instance.getTodos(username);
      notifyListeners();
    } catch (e) {
      return e.toString();
    }
    return 'OK';
  }

  Future<String> deleteTodo(Todo todo) async {
    try {
      await DatabaseConnect.instance.deleteTodo(todo);
    } catch (e) {
      return e.toString();
    }
    String result = await getTodos(todo.username);
    return result;
  }

  Future<String> deleteAllTodos() async {
    try {
      await DatabaseConnect.instance.deleteAllTodos();
    } catch (e) {
      return e.toString();
    }
    return 'OK';
  }

  Future<String> createTodo(Todo todo) async {
    try {
      await DatabaseConnect.instance.createTodo(todo);
    } catch (e) {
      e.toString();
    }
    String result = await getTodos(todo.username);
    return result;
  }

  Future<String> updateTodo(Todo todo) async {
    try {
      await DatabaseConnect.instance.updateTodo(todo);
    } catch (e) {
      e.toString();
    }
    String result = await getTodos(todo.username);
    return result;
  }

  Future<String> toggleTodoDone(Todo todo) async {
    try {
      await DatabaseConnect.instance.toggleTodoDone(todo);
    } catch (e) {
      e.toString();
    }
    String result = await getTodos(todo.username);
    return result;
  }
}
