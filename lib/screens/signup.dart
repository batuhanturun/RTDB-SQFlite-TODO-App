// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/models/todo_model.dart';
import 'package:sqflite_todo/screens/verifyemail.dart';
import 'package:sqflite_todo/services/user_service.dart';
import 'package:sqflite_todo/utils/color.dart';
import 'package:sqflite_todo/widgets/dialogs.dart';
import 'package:sqflite_todo/widgets/re_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController _passwordTextController;
  late TextEditingController _repasswordTextController;
  late TextEditingController _emailTextController;
  late TextEditingController _usernameTextController;

  @override
  void initState() {
    super.initState();
    _repasswordTextController = TextEditingController();
    _usernameTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    _emailTextController = TextEditingController();
  }

  @override
  void dispose() {
    _repasswordTextController.dispose();
    _passwordTextController.dispose();
    _emailTextController.dispose();
    _usernameTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Sign Up",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            hexStringToColor("5CBA80"),
            hexStringToColor("4E8570"),
            hexStringToColor("214938")
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.2, 20, 0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  reTextField("Enter Name", Icons.person_outline, false,
                      _usernameTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reTextField(
                      "Enter Email", Icons.email, false, _emailTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reTextField("Enter Password",
                      Icons.lock_outline, true, _passwordTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  reTextField("Enter Re-Password", Icons.lock_outline, true,
                      _repasswordTextController),
                  const SizedBox(
                    height: 20,
                  ),
                  signInUpButton(context, false, () async {
                    if (_repasswordTextController.text !=
                        _passwordTextController.text) {
                      showSnackBar(context, 'Please check your passwords!');
                    } else {
                      int parse = int.parse(_passwordTextController.text);
                      if (parse > 99999) {
                        try {
                          String result2 = await context
                              .read<UserService>()
                              .checkIfUserExists(_emailTextController.text);
                          if (result2 == 'OK') {
                            context.read<UserService>().userExists = true;
                          } else {
                            context.read<UserService>().userExists = false;
                            Users users = Users(
                                username: _emailTextController.text,
                                name: _usernameTextController.text);
                            String result3 = await context
                                .read<UserService>()
                                .createUser(users);
                            if (result3 != 'OK') {
                              showSnackBar(context, result3);
                            } else {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _emailTextController.text,
                                      password: _passwordTextController.text)
                                  .then((value) {
                                value.user!.updateDisplayName(
                                    _usernameTextController.text);
                                value.user!.reload();
                                showSnackBar(
                                    context, 'New user successfully created!');
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const VerifyEmailPage()));
                              });
                            }
                          }
                        } on FirebaseAuthException catch (eror) {
                          Fluttertoast.showToast(
                              msg: eror.message.toString(),
                              gravity: ToastGravity.TOP,
                              textColor: Colors.white,
                              backgroundColor: Colors.red);
                        }
                      } else {
                        showSnackBar(context, 'Enter 6 character password');
                      }
                    }
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
