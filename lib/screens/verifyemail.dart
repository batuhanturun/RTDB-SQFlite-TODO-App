// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/screens/homepage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite_todo/screens/signin.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/services/user_service.dart';
import 'package:sqflite_todo/utils/color.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });
    if (isEmailVerified) {
      String username = FirebaseAuth.instance.currentUser!.email.toString();
      await context.read<UserService>().getUser(username);
      await context.read<TodoService>().getTodos(username);
      timer?.cancel();
    }
  }

  Future sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 3));
      setState(() => canResendEmail = true);
    } catch (eror) {
      Fluttertoast.showToast(
          msg: eror.toString(),
          gravity: ToastGravity.TOP,
          textColor: Colors.white,
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const HomePage()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text('Verify E-Mail'),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                hexStringToColor("D9C7DD"),
                hexStringToColor("5A4060"),
                hexStringToColor("D4AB86")
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'A verification email has been sent your email.',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90)),
                      child: ElevatedButton(
                          onPressed: () {
                            canResendEmail ? sendVerificationEmail() : null;
                          },
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.black26;
                                }
                                return Colors.white;
                              }),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30)))),
                          child: const Text(
                            "Resent E-Mail",
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(90)),
                      child: ElevatedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignInScreen()));
                        },
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith((states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.black87;
                              }
                              return Colors.red;
                            }),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)))),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
