// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/models/todo_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/widgets/dialogs.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  const TodoCard({Key? key, required this.todo}) : super(key: key);

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  late TextEditingController todoEditController;

  @override
  void initState() {
    super.initState();
    todoEditController = TextEditingController();
  }

  @override
  void dispose() {
    todoEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = FirebaseAuth.instance.currentUser;
    return Slidable(
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              var service = context.read<TodoService>();
              Todo todoRep = Todo(
                  username: widget.todo.username,
                  title: widget.todo.title,
                  id: widget.todo.id,
                  creationDate: widget.todo.creationDate,
                  isChecked: widget.todo.isChecked);
              DatabaseReference refDel = FirebaseDatabase.instance
                  .ref('deleted/${currentUser!.uid}/${widget.todo.id}');
              refDel.push().set(widget.todo.toJson()).asStream();
              DatabaseReference refAdd = FirebaseDatabase.instance
                  .ref('todos/${currentUser.uid}/${widget.todo.id}');
              refAdd.remove();
              String result = await service.deleteTodo(widget.todo);
              if (result != 'OK') {
                showSnackBar(context, result);
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: const Duration(seconds: 5),
                  elevation: 10,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                  )),
                  content: Text('${widget.todo.title} is delete soon!'),
                  action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        service.createTodo(todoRep);
                        var currentUsers = FirebaseAuth.instance.currentUser;
                        DatabaseReference refAdd = FirebaseDatabase.instance
                            .ref('todos/${currentUsers!.uid}/${todoRep.id}');
                        refAdd.set(todoRep.toJson()).asStream();
                        DatabaseReference refDel = FirebaseDatabase.instance
                            .ref('deleted/${currentUser.uid}/${todoRep.id}');
                        refDel.remove();
                      })));
            },
            icon: Icons.delete,
            backgroundColor: Colors.red,
            label: 'Delete',
          )
        ],
      ),
      child: GestureDetector(
        onLongPress: () async {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('Edit TODO'),
                  content: TextField(
                    decoration:
                        const InputDecoration(hintText: 'Please enter TODO'),
                    controller: todoEditController,
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () async {
                          if (todoEditController.text.isEmpty) {
                            showSnackBar(context,
                                'Please enter a TODO first, then save!');
                          } else {
                            DatabaseReference refUpd = FirebaseDatabase.instance
                                .ref(
                                    'todos/${currentUser!.uid}/${widget.todo.id}');
                            refUpd.update({
                              'title': widget.todo.title =
                                  todoEditController.text
                            });
                            String result = await context
                                .read<TodoService>()
                                .updateTodo(widget.todo);
                            if (result != 'OK') {
                              showSnackBar(context, result);
                            }
                            todoEditController.text = '';
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'))
                  ],
                );
              });
        },
        child: Card(
          color: Colors.purple.shade300,
          child: CheckboxListTile(
            checkColor: Colors.purple,
            activeColor: Colors.purple[100],
            value: widget.todo.isChecked, 
            onChanged: (value) async {
              String result =
                  await context.read<TodoService>().toggleTodoDone(widget.todo);
              if (result != 'OK') {
                showSnackBar(context, result);
              }
              DatabaseReference refAdd = FirebaseDatabase.instance
                  .ref('todos/${currentUser!.uid}/${widget.todo.id}');
              if (widget.todo.isChecked == true) {
                refAdd.update({'isChecked': widget.todo.isChecked == true});
              } else {
                refAdd.update({'isChecked': widget.todo.isChecked == true});
              }
            },
            subtitle: Text(
              '${widget.todo.creationDate.day}/${widget.todo.creationDate.month}/${widget.todo.creationDate.year}', 
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            title: Text(
              widget.todo.title, 
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  decoration: widget.todo.isChecked 
                      ? TextDecoration.lineThrough
                      : TextDecoration.none),
            ),
          ),
        ),
      ),
    );
  }
}
