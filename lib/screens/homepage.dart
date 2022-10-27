// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/models/todo_model.dart';
import 'package:sqflite_todo/screens/signin.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/services/user_service.dart';
import 'package:sqflite_todo/widgets/dialogs.dart';
import 'package:sqflite_todo/widgets/todo_card.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUsers = FirebaseAuth.instance.currentUser;
    Query dbQuery =
        FirebaseDatabase.instance.ref().child('todos').child(currentUsers!.uid);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.purple, Colors.blue, Colors.white],
        )),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  title: const Text('Create a new TODO'),
                                  content: TextField(
                                    decoration: const InputDecoration(
                                        hintText: 'Please enter TODO'),
                                    controller: todoController,
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () async {
                                          if (todoController.text.isEmpty) {
                                            showSnackBar(context,
                                                'Please enter a TODO first, then save!');
                                          } else {
                                            var uuid = const Uuid();
                                            String idG = uuid.v1();
                                            String username = context
                                                .read<UserService>()
                                                .currentUser
                                                .username;
                                            Todo todo = Todo(
                                                id: idG,
                                                username: username,
                                                title: todoController.text,
                                                creationDate: DateTime.now(),
                                                isChecked: false);
                                            String result = await context
                                                .read<TodoService>()
                                                .createTodo(todo);
                                            if (result == 'OK') {
                                              DatabaseReference refAdd =
                                                  FirebaseDatabase.instance.ref(
                                                      'todos/${currentUsers.uid}/${todo.id}');
                                              refAdd
                                                  .set(todo.toJson())
                                                  .asStream();
                                              showSnackBar(context,
                                                  'New TODO successfully added!');
                                              todoController.text = '';
                                            } else {
                                              showSnackBar(context, result);
                                            }
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Save'))
                                  ],
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 30,
                        )),
                    IconButton(
                        onPressed: () {
                          context.read<TodoService>().deleteAllTodos();
                          FirebaseAuth.instance.signOut().then((value) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignInScreen()));
                          });
                          showSnackBar(context,
                              '${currentUsers.email} successfully logout!');
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.white,
                          size: 30,
                        ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                      '${FirebaseAuth.instance.currentUser!.displayName}\'s TODO List',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w200,
                          color: Colors.white),
                    )
              ),
              FutureBuilder(
                future: getStringList(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 20.0),
                        child: Consumer<TodoService>(
                          builder: (context, value, child) {
                            return RefreshIndicator(
                              triggerMode: RefreshIndicatorTriggerMode.onEdge,
                              color: Colors.grey,
                              backgroundColor: Colors.black26,
                              onRefresh: _refresh,
                              child: ListView.builder(
                                itemCount: value.todos.length,
                                itemBuilder: (context, index) {
                                  if (value.todos.isEmpty) {
                                    return const Center(
                                      child: Text('TODO List is Empty',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    );
                                  } else {
                                    return TodoCard(todo: value.todos[index]);
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ));
                    case ConnectionState.done:
                      return Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 20),
                        child: RefreshIndicator(
                          triggerMode: RefreshIndicatorTriggerMode.onEdge,
                          color: Colors.grey,
                          backgroundColor: Colors.black26,
                          onRefresh: _refresh,
                          child: FirebaseAnimatedList(
                              query: dbQuery,
                              itemBuilder: (BuildContext context,
                                  DataSnapshot snapshot,
                                  Animation<double> animation,
                                  int index) {
                                Map todoOn = snapshot.value as Map;
                                Todo todo2 = Todo(
                                    id: todoOn['id'],
                                    username: todoOn['username'],
                                    title: todoOn['title'],
                                    creationDate:
                                        DateTime.parse(todoOn['creationDate']),
                                    isChecked: todoOn['isChecked']);
                                todoOn['id'] = snapshot.key;
                                if (snapshot.value == null) {
                                  return const Center(
                                    child: Text('TODO List is Empty',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold)),
                                  );
                                } else {
                                  return TodoCard(todo: todo2);
                                }
                              }),
                        ),
                      ));
                    case ConnectionState.none:
                      return Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 20.0),
                        child: Consumer<TodoService>(
                          builder: (context, value, child) {
                            return RefreshIndicator(
                              triggerMode: RefreshIndicatorTriggerMode.onEdge,
                              color: Colors.grey,
                              backgroundColor: Colors.black26,
                              onRefresh: _refresh,
                              child: ListView.builder(
                                itemCount: value.todos.length,
                                itemBuilder: (context, index) {
                                  return TodoCard(todo: value.todos[index]);
                                },
                              ),
                            );
                          },
                        ),
                      ));
                    default:
                      return const Expanded(
                          child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                        child: Center(child: Text('Something went wrong')),
                      ));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() {
    FirebaseAuth.instance.currentUser!.reload();
    return Future.delayed(const Duration(seconds: 1));
  }

  Future getStringList() async {
    var currentUserUID = FirebaseAuth.instance.currentUser!.uid;
    Query dbRef =
        FirebaseDatabase.instance.ref().child('todos').child(currentUserUID);
    DataSnapshot snapshot = await dbRef.get();
    if (snapshot.value != null) {
      Map readTodo = snapshot.value as Map;
      return Future.delayed(const Duration(seconds: 1))
          .then((value) => readTodo);
    } else {
      return const Center(child: Text('No TODO Found'));
    }
  }
}
