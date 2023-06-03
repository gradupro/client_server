import 'package:emerdy_client/controllers/main_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// Import screens for routing
import 'screens/login_screen.dart';
import 'screens/protectorlist_screen.dart';
import 'screens/reportlist_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/protectlist_screen.dart';
import 'screens/acceptProtector_screen.dart';


// Import controller
import 'controllers/receiveNotiforProtector_controller.dart';
import 'controllers/trigger_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));
  Get.put(TriggerController());
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.data}");

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'noti_channel',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.show(
    0,
    'Push Notification',
    message.data.toString(),
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );

  // Navigating to AcceptProtectorScreen when notification is clicked
  Get.to(() => ProtectorRequestScreen());
}

void _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  print("Received a foreground message: ${message.data}");
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails('noti_channel', 'your_channel_name',
      importance: Importance.max, priority: Priority.high);
  const NotificationDetails platformChannelSpecifics =
  NotificationDetails(android: androidPlatformChannelSpecifics);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.show(
    0,
    'Push Notification',
    message.data.toString(),
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );

  Get.to(() => ProtectorRequestScreen());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isFirstTime = false;
  bool _hasPermissions = false;
  late MainController _mainController;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final TriggerController _triggerController = Get.find<TriggerController>();

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _checkAndRequestPermissions();
    _mainController = MainController();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
    initializeNotifications();
    _triggerController.initialize();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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

    // Check if microphone permission is granted
    if (microphoneStatus != PermissionStatus.granted) {
      // Request microphone permission
      var result = await Permission.microphone.request();
      if (result == PermissionStatus.granted) {
        setState(() {
          _hasPermissions = true;
        });
      } else {
        setState(() {
          _hasPermissions = false;
        });
      }
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
      initialScreen = MainScreen(controller: _mainController);
    }

    return GetMaterialApp(
      title: 'EmerDy',
      home: initialScreen,
      routes: {
        '/main_screen': (context) => MainScreen(controller: _mainController),
        '/login_screen': (context) => LoginScreen(),
        '/signup_screen': (context) =>
            SignUpScreen(onSignUpComplete: _updateFirstTime),
        '/reportlist_screen': (context) => ReportListScreen(),
        '/protectlist_screen': (context) => ProtectListScreen(),
        '/protectorlist_screen': (context) => ProtectorListScreen(),
        '/AcceptProtector_screen': (context) => ProtectorRequestScreen(),
      },
    );
  }
}
