// ignore_for_file: unnecessary_this, avoid_renaming_method_parameters, prefer_const_declarations, non_constant_identifier_names

final String todoTable = 'todo';

class TodoFields {
  static final String id = 'id';
  static final String username = 'username';
  static final String title = 'title';
  static final String creationDate = 'creationDate';
  static final String isChecked = 'isChecked';
  static final List<String> allFields = [
    id,
    username,
    title,
    creationDate,
    isChecked
  ];
}

class Todo {
  final String id;
  final String username;
  String title;
  final DateTime creationDate;
  bool isChecked;

  Todo(
      {required this.username,
      required this.title,
      required this.id,
      required this.creationDate,
      this.isChecked = false});
      
  Map<String, Object?> toJson() => {
        TodoFields.id: id,
        TodoFields.username: username,
        TodoFields.title: title,
        TodoFields.isChecked: isChecked,
        TodoFields.creationDate: creationDate.toIso8601String()
      };

  static Todo fromJson(Map<String, Object?> json) => Todo(
      id: json[TodoFields.id] as String,
      username: json[TodoFields.username] as String,
      title: json[TodoFields.title] as String,
      creationDate: DateTime.parse(json[TodoFields.creationDate] as String),
      isChecked: json[TodoFields.isChecked] == 1 ? true : false);

  @override
  bool operator ==(covariant Todo todo) {
    return (this.username == todo.username) &&
        (this.title.toUpperCase().compareTo(todo.title.toUpperCase()) == 0);
  }

  @override
  int get hashCode {
    return Object.hash(username, title);
  }
}

final String userTable = 'user';

class UserFields {
  static final String username = 'username';
  static final String name = 'name';
  static final List<String> allFields = [username, name];
}

class Users {
  final String username;
  String name;

  Users({required this.username, required this.name});
  Map<String, Object?> toJson() => {
        UserFields.username: username,
        UserFields.name: name,
      };

  static Users fromJson(Map<String, Object?> json) =>
      Users(username: json['username'] as String, name: json['name'] as String);
}
