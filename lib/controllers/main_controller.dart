import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class MainController {
  Future<String?> getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // Request permission for notification if not granted
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // Get the device token
      String? token = await messaging.getToken();
      return token;
    } catch (e) {
      print('Error getting device token: $e');
      return null;
    }
  }

  Future<void> sendDeviceInfo(String deviceToken) async {
    // Replace 'YOUR_SERVER_URL' with your actual server URL
    final url = Uri.parse('YOUR_SERVER_URL');

    // Replace 'GCP' with the appropriate device type value
    final deviceType = 'GCP';

    try {
      final response = await http.post(
        url,
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
