import 'package:emerdy_client/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import "package:firebase_auth/firebase_auth.dart";
import 'screens/auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/notificationMessage.dart';
import 'screens/protect_list.dart';
import 'screens/report_screen.dart';
import 'screens/signup_screen.dart';

void main() {
  runApp(MyApp());
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = false;
  //bool _isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('isFirstTime') ?? true;
  }

  void _updateFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: _isFirstTime ? '/auth_screen' : '/reportall',
      routes: {
        MainPage.routeName:(context) => main_page(),
        AuthScreen.routeName: (context) => auth_screen(onSignUpComplete: _updateFirstTime),
      },
    );
  }
}