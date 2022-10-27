import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite_todo/screens/service.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const ServiceScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image.asset('assets/images/logo2.png'),
    );
  }
}
