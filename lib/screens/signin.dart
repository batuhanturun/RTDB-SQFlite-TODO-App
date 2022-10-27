// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print

import 'package:flutter/material.dart';
import 'package:sqflite_todo/models/todo_model.dart';
import 'package:sqflite_todo/screens/forgetpassword.dart';
import 'package:sqflite_todo/screens/verifyemail.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/services/user_service.dart';
import 'package:sqflite_todo/utils/color.dart';
import 'package:sqflite_todo/widgets/re_widget.dart';
import 'package:sqflite_todo/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _fromkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late TextEditingController _passwordTextController;
  late TextEditingController _emailTextController;
  late Users users;

  @override
  void initState() {
    _emailTextController = TextEditingController();
    _passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    _passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              hexStringToColor("BFF3AC"),
              hexStringToColor("BF98FF"),
              hexStringToColor("000000")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _fromkey,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20,
                      MediaQuery.of(context).size.height * 0.262, 20, 0), //254
                  child: Column(
                    children: <Widget>[
                      logoWidget("assets/images/logo.png"),
                      const Text('TODO APP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                      const SizedBox(height: 10),
                      reTextField("Enter Email", Icons.email, false,
                          _emailTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      reTextField('Enter Password', Icons.lock_outline, true,
                          _passwordTextController),
                      const SizedBox(
                        height: 20,
                      ),
                      const SizedBox(height: 10),
                      signInUpButton(context, true, () async {
                        try {
                          String result = await context
                              .read<UserService>()
                              .getUser(_emailTextController.text);
                          if (result == 'OK') {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text)
                                .then((value) {
                              String username = context
                                  .read<UserService>()
                                  .currentUser
                                  .username;
                              context.read<TodoService>().getTodos(username);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyEmailPage()));
                            });
                          } else {
                            FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                    email: _emailTextController.text,
                                    password: _passwordTextController.text)
                                .then((value) async {
                              Users users = Users(
                                  username: value.user!.email.toString(),
                                  name: value.user!.displayName.toString());
                              context.read<UserService>().createUser2(users);

                              context
                                  .read<UserService>()
                                  .getUser(users.username);
                              context.read<TodoService>().getTodos(users.username);

                              context
                                  .read<TodoService>()
                                  .getTodos(users.username);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const VerifyEmailPage()));
                            });
                          }
                        } on FirebaseAuthException catch (eror) {
                          Fluttertoast.showToast(
                              msg: eror.message.toString(),
                              gravity: ToastGravity.TOP,
                              textColor: Colors.white,
                              backgroundColor: Colors.red);
                        }
                      }),
                      forgetPassword(),
                      signUpOption(),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Row forgetPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ForgetPasswordScreen()));
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  Row signUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()));
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
