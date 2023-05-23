import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationController {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  PushNotificationController() {
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<bool> receivePushNotification() async {
    final String serverURL =
        'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/user/protector/request';

    try {
      final response = await http.get(Uri.parse(serverURL));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final wardData = jsonData['data'][0]['ward'];
        final requesterName = wardData['name'];
        final requesterPhoneNumber = wardData['phone_number'];

        // Display a notification to the user
        await showNotification(requesterName, requesterPhoneNumber);
        print(requesterName);
        print(requesterPhoneNumber);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> showNotification(
      String requesterName, String requesterPhoneNumber) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'noti_channel',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Protector Request',
      'Requester: $requesterName\nPhone Number: $requesterPhoneNumber',
      platformChannelSpecifics,
      payload: 'notification_payload', // Add a payload if required
    );
    print(requesterName);
  }

  static Future<bool> sendProtectorResponse(bool accepted) async {
    final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
    final String serverURL =
        'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/user/protector/allow';
    final String? jwt = await _secureStorage.read(key: 'jwt');

    try {
      final response = await http.post(
        Uri.parse(serverURL),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 202) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
