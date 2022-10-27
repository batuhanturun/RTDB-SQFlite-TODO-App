import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_todo/screens/splash.dart';
import 'package:sqflite_todo/services/todo_service.dart';
import 'package:sqflite_todo/services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => UserService(),
      ),
      ChangeNotifierProvider(
        create: (context) => TodoService(),
      ),
    ],
    child: const MaterialApp(
      home: MyApp(),
      debugShowCheckedModeBanner: false,
    ),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Splash();
  }
}


/*
  keytool -list -v -keystore "C:\Users\Acer Nitro 5\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
  https://fonts.google.com/icons?selected=Material+Icons&icon.query=exit
  https://medium.com/@juliomacr/10-firebase-realtime-database-rule-templates-d4894a118a98
  git status
  git add .
  git commit -m "Updated"
  git push
*/