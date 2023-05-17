import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class ActivateNotifunc extends GetxController {
  String serverUrl = "http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/auth/code";

  bool isNotiActivated = false;
  Future<void> ActivateNoti() async {
    var response = await http.get(Uri.parse('$serverUrl/activate_plugins'));
    if (response.statusCode == 200) {
      print("Notification plugin activated.");
      isNotiActivated = true; // Set flag to true after successful activation
    } else {
      print("Error activating notification plugin: ${response.statusCode}");
    }
  }
}