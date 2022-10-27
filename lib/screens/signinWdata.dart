// ignore_for_file: use_build_context_synchronously, file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/screens/forgetpassword.dart';
import 'package:sqflite_todo/screens/signin.dart';
import 'package:sqflite_todo/screens/signup.dart';
import 'package:sqflite_todo/screens/verifyemail.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/services/user_service.dart';
import 'package:sqflite_todo/utils/color.dart';
import 'package:sqflite_todo/widgets/dialogs.dart';
import 'package:sqflite_todo/widgets/re_widget.dart';

class SignInScreen2 extends StatefulWidget {
  const SignInScreen2({Key? key}) : super(key: key);

  @override
  State<SignInScreen2> createState() => _SignInScreen2State();
}

class _SignInScreen2State extends State<SignInScreen2> {
  final GlobalKey<FormState> _fromkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _passwordTextController;

  @override
  void initState() {
    _passwordTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentUser = FirebaseAuth.instance.currentUser!.email.toString();
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
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          child: SingleChildScrollView(
            child: Form(
              key: _fromkey,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).size.height * 0.3131, 20, 0),
                child: Column(
                  children: <Widget>[
                    logoWidget('assets/images/logo.png'),
                    const Text('TODO APP', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),),
                      const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.person, size: 30, color: Colors.green),
                        const SizedBox(width: 5),
                        Text(currentUser,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            context.read<TodoService>().deleteAllTodos();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignInScreen()));
                          },
                          icon: const Icon(Icons.cancel),
                          color: Colors.white70,
                          iconSize: 22,
                          alignment: Alignment.centerRight,
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    reTextField('Enter Password', Icons.lock_outline, true,
                        _passwordTextController),
                    const SizedBox(
                      height: 20,
                    ),
                    signInUpButton(context, true, () async {
                      try {
                        String result = await context
                            .read<UserService>()
                            .getUser(currentUser);
                        if (result != 'OK') {
                          showSnackBar(context, result);
                        } else {
                          String username =
                              context.read<UserService>().currentUser.username;
                          context.read<TodoService>().getTodos(username);
                          await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: currentUser,
                                  password: _passwordTextController.text)
                              .then((value) {
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
                ),
              ),
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
