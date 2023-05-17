import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

class MyController extends GetxController {
  String serverUrl = "http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/auth/code";

  Future<bool> triggerOccur() async {

    //동작 트리거 여기에 넣기
    //triggerEvent();

    final response = await http.post(
      Uri.parse('http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report'),
      body: {'message': 'Trigger has occurred'},
    );
    if (response.statusCode == 200) {
      print('Notification request sent successfully');
    } else {
      print('Failed to send notification request');
    }
    return true;
  }
  // 동작트리거에 대한 정확한 서술
  // void triggerEvent(){};
}