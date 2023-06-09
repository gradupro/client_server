import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class IsInterruptController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> IsInterrupted(int reportId) async {
    final String? jwt = await _secureStorage.read(key: 'jwt');
    final url = "http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report/interrupt?id=$reportId";
    try {
      // Create the PUT request
      final response = await http.put(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $jwt'},
      );

      if (response.statusCode == 200) {
        print('Report status updated');
      } else {
        print('Failed to update report status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating report status: $error');
    }
  }
}
