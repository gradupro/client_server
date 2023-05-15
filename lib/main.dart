import 'package:emerdy_client/controllers/main_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Import screens for routing
import 'screens/login_screen.dart';
import 'screens/protectorlist_screen.dart';
import 'screens/reportlist_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/protectlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = false;
  bool _hasPermissions = false;
  late MainController _mainController;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _checkAndRequestPermissions();
    _mainController = MainController();
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
    var locationStatus = await Permission.location.status;
    var notificationStatus = await Permission.notification.status;
    var microphoneStatus = await Permission.microphone.status;

    // Check if Firebase Messaging permission is granted
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      setState(() {
        _hasPermissions = true;
      });
    } else {
      setState(() {
        _hasPermissions = false;
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
      initialScreen = MainScreen(controller: _mainController);
    }

    return MaterialApp(
      title: 'My App',
      home: initialScreen,
      routes: {
        '/main_screen': (context) => MainScreen(controller: _mainController),
        '/login_screen': (context) => LoginScreen(),
        '/signup_screen': (context) =>
            SignUpScreen(onSignUpComplete: _updateFirstTime),
        '/reportlist_screen': (context) => ReportListScreen(),
        '/protectlist_screen': (context) => ProtectListScreen(),
        '/protectorlist_screen': (context) => ProtectorListScreen(),
      },
    );
  }
}
