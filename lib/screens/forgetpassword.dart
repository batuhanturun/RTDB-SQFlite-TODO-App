import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite_todo/utils/color.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Reset Password'),
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              hexStringToColor("ECBCA4"),
              hexStringToColor("A4747C"),
              hexStringToColor("6F6068")
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Receive an email to\nreset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: emailController,
                        cursorColor: Colors.white,
                        enableSuggestions: true,
                        autocorrect: true,
                        maxLength: 40,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                            prefix:
                                const Icon(Icons.email, color: Colors.white70),
                            labelText: 'Enter Email',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: const BorderSide(
                                    width: 0, style: BorderStyle.none)),
                            filled: true,
                            counterText: "",
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            errorStyle: const TextStyle(color: Colors.amberAccent, fontSize: 15, fontWeight: FontWeight.bold),
                            labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                            fillColor: Colors.white.withOpacity(0.3)),
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? 'Please enter a valid email!'
                                : null,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(90)),
                          child: ElevatedButton(
                            onPressed: () {
                              resetPassword();
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
                              'Reset Password',
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ))
                    ],
                  ),
                )),
          ),
        ),
      );
  Future resetPassword() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      Fluttertoast.showToast(
          msg: 'Password Reset E-Mail Sent',
          gravity: ToastGravity.TOP,
          textColor: Colors.white,
          backgroundColor: Colors.green);
      // ignore: use_build_context_synchronously
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (eror) {
      Fluttertoast.showToast(
          msg: eror.message.toString(),
          gravity: ToastGravity.TOP,
          textColor: Colors.white,
          backgroundColor: Colors.red);
      Navigator.of(context).pop();
    }
  }
}
