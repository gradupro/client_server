import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

class AddProtectorController {
  static Future<bool> addProtector(String phoneNumber) async {
    // Your server URL for adding a protector
    final String serverURL = 'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/user/protector';
    final String? jwt = await _secureStorage.read(key: 'jwt');

    try {
      // Make a POST request to the server with the phone number
      final response = await http.post(
        Uri.parse(serverURL),
        headers: {
          'Authorization' : 'Bearer $jwt',
        },
        body: {'phone_number': phoneNumber},
      );

      // Check the response status code
      if (response.statusCode == 200) {
        // Successfully added the protector
        return true;
      } else {
        // Failed to add the protector
        return false;
      }
    } catch (e) {
      // An error occurred during the network request
      return false;
    }
  }
}
