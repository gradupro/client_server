import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '/models/user_model.dart';
import 'signup_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class MainController {
  final dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // Request permission for notification if not granted
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      // Get the device token
      String? token = await messaging.getToken();
      print('devicetoken: $token');
      return token;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  Future<void> sendDeviceInfo(String deviceToken) async {
    final String? jwt = await _secureStorage.read(key: 'jwt');
    final url = Uri.parse('http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/user/device');
    final deviceType = 'GCM';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization' : 'Bearer $jwt',
        },
        body: {
          'deviceToken': deviceToken,
          'deviceType': deviceType,
        },
      );

      // Handle the server response here if needed
      print('Device info sent successfully');
    } catch (e) {
      print('Error sending device info: $e');
    }
  }
}
