import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '/screens/reportdetail_screen.dart';
import '/controllers/ActivateNoti.dart';

class AppController extends GetxController {
  static AppController get to => Get.find();

  final Rxn<RemoteMessage> message = Rxn<RemoteMessage>();
  bool isNotiActivated = false;

  Future<void> initialize() async {
    // Firebase initialization must be done first to use Firebase Messaging.
    await Firebase.initializeApp();

    // Activate notification plugin
    await ActivateNotifunc();

    // Android 에서는 별도의 확인 없이 리턴되지만, requestPermission()을 호출하지 않으면 수신되지 않는다.
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // User has granted notification permission
    } else {
      // User has not granted notification permission
    }

    // Notification Channel
    const AndroidNotificationChannel androidNotificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel', // 임의의 id
      'High Importance Notifications', // 설정에 보일 채널명
      'This channel is used for important notifications.', // 설정에 보일 채널 설명
      importance: Importance.max,
    );

    // Notification Channel을 디바이스에 생성
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);

    // FlutterLocalNotificationsPlugin 초기화.
    await flutterLocalNotificationsPlugin.initialize(
        InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            //iOS: IOSInitializationSettings()),
        onSelectNotification: (String? payload) async {
          // Foreground 에서 수신했을 때 생성되는 heads up notification 클릭했을 때의 동작
          Get.to(ReportScreen(), arguments: payload);
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage rm) {
      message.value = rm;
      RemoteNotification? notification = rm.notification;
      AndroidNotification? android = rm.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // 임의의 id
              'High Importance Notifications', // 설정에 보일 채널명
              'This channel is used for important notifications.', // 설정에 보일 채널 설명
              // other properties...
            ),
          ),
          // data 영역의 임의의 필드(ex. argument)를 사용한다.
          payload: rm.data['argument'],
        );
      }
    });

    // Background 상태. Notification 서랍에서 메시지 터치하여 앱으로 돌아왔을 때의 동작은 여기서.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage rm) {
      Get.to(ReportDetaiScreen(), arguments: rm.data['argument']);
    });

    // Terminated 상태에서 도착한 메시지에 대한 처리
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Get.to(ReportScreen(),
          arguments: initialMessage.data['argument']);
    }
  }
}
