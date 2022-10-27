import 'package:flutter/material.dart';
import 'package:sqflite_todo/models/sqflite_model.dart';
import 'package:sqflite_todo/models/todo_model.dart';

class UserService with ChangeNotifier {
  late Users _currentUser;
  bool _busyCreate = false;
  bool _userExists = false;

  Users get currentUser => _currentUser;
  bool get busyCreate => _busyCreate;
  bool get userExists => _userExists;

  set userExists(bool value) {
    _userExists = value;
    notifyListeners();
  }

  Future<String> getUser(String username) async {
    String result = 'OK';
    try {
      _currentUser = await DatabaseConnect.instance.getUser(username);
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> checkIfUserExists(String username) async {
    String result = 'OK';
    try {
      await DatabaseConnect.instance.getUser(username);
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> updateCurrentUser(String name) async {
    String result = 'OK';
    _currentUser.name = name;
    notifyListeners();
    try {
      await DatabaseConnect.instance.updateUser(_currentUser);
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    return result;
  }

  Future<String> createUser(Users users) async {
    String result = 'OK';
    _busyCreate = true;
    notifyListeners();
    try {
      await DatabaseConnect.instance.createUser(users);
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    _busyCreate = false;
    notifyListeners();
    return result;
  }

  Future<String> createUser2(Users users) async {
    String result = 'OK';
    notifyListeners();
    try {
      await DatabaseConnect.instance.createUser(users);
    } catch (e) {
      result = getHumanReadableError(e.toString());
    }
    notifyListeners();
    return result;
  }
}

String getHumanReadableError(String message) {
  if (message.contains('UNIQUE constraint failed')) {
    return 'This user already exists in the database. Please choose a new one.';
  }
  if (message.contains('not found in the database')) {
    return 'The user does not exist in the database. Please register first';
  }
  return message;
}
