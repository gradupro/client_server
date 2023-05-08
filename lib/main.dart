import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screens/Auth_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reportlist_screen.dart';
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
  bool _hasPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _checkAndRequestPermissions();
  }

  void _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  void _updateFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  Future<void> _checkAndRequestPermissions() async {
    // 권한 확인
    var locationStatus = await Permission.location.status;
    var notificationStatus = await Permission.notification.status;
    var microphoneStatus = await Permission.microphone.status;
    var audioStatus = await Permission.audio.status;

    // 권한 없을 시 요청
    if (!locationStatus.isGranted ||
        !notificationStatus.isGranted ||
        !microphoneStatus.isGranted ||
        !audioStatus.isGranted) {
      setState(() {
        _hasPermissions = false;
      });
    } else {
      setState(() {
        _hasPermissions = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget initialScreen;
    if (_isFirstTime) {
      if (_hasPermissions) {
        initialScreen = SignUpScreen(onSignUpComplete: _updateFirstTime);
      } else {
        initialScreen = PermissionScreen(onPermissionGranted: () {
          _checkAndRequestPermissions();
        });
      }
    } else {
      initialScreen = LoginScreen();
    }

    return MaterialApp(
      title: 'My App',
      home: initialScreen,
      routes: {
        '/login_screen': (context) => LoginScreen(),
        '/signup_screen': (context) => SignUpScreen(onSignUpComplete: _updateFirstTime),
        '/reportlist_screen': (context) => ReportListScreen(),
      },
    );
  }
}
