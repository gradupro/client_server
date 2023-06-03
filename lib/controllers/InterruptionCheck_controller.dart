import 'dart:convert';
import 'package:http/http.dart' as http;

class InterruptionCheckController {

  Future<bool> checkInterruption(int reportId) async {
    final url =
        'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report?id=$reportId';
    final response = await http.get(Uri.parse(url));
    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final interruptionStatus = data['interruption'];

        return interruptionStatus;
      } else {
        return false; // return false when status code is not 200
      }
    } catch (e) {
      print('error: $e');
      return false; // return false when an exception is caught
    }
  }
}

