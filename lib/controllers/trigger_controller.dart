import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TriggerController extends GetxController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<void> initialize() async {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double magnitude = calculateAccelerationMagnitude(event);

      double shakeThreshold = 0.01; // Adjust this value as needed
      Duration shakeDuration = Duration(seconds: 2); // Adjust this duration as needed

      if (magnitude > shakeThreshold) {
        Timer(Duration.zero, () {
          Timer(shakeDuration, () {
            if (magnitude > shakeThreshold) {
              triggerEvent();
            }
          });
        });
      }
    });
  }

  double calculateAccelerationMagnitude(AccelerometerEvent event) {
    double x = event.x;
    double y = event.y;
    double z = event.z;
    return sqrt(x * x + y * y + z * z);
  }

  Future<void> triggerEvent() async {
    final String? jwt = await _secureStorage.read(key: 'jwt');
    final response = await http.post(
      Uri.parse('http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report'),
      headers: {'Authorization': 'Bearer $jwt'},
    );
    if (response.statusCode == 200) {
      print('Notification request sent successfully');
    } else {
      print('Failed to send notification request');
    }
  }
}
