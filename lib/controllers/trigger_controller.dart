import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';

class TriggerController extends GetxController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isRecording = false;
  late FlutterSoundRecorder _audioRecorder;

  Future<void> initialize() async {
    _audioRecorder = FlutterSoundRecorder();

    accelerometerEvents.listen((AccelerometerEvent event) {
      if (!_isRecording) {
        double magnitude = calculateAccelerationMagnitude(event);

        double shakeThreshold = 40; // Adjust this value as needed
        Duration shakeDuration = Duration(seconds: 2); // Adjust this duration as needed

        if (magnitude > shakeThreshold) {
          Timer(Duration.zero, () {
            Timer(shakeDuration, () {
              if (magnitude > shakeThreshold) {
                print('Shake event detected');
                triggerEvent();
              }
            });
          });
        }
      }
    });
  }

  double calculateAccelerationMagnitude(AccelerometerEvent event) {
    double x = event.x;
    double y = event.y;
    double z = event.z;
    double magnitude = sqrt(x * x + y * y + z * z);
    return magnitude;
  }

  Future<void> triggerEvent() async {
    final String? jwt = await _secureStorage.read(key: 'jwt');
    if (jwt != null) {
      if (!_isRecording) {
        _isRecording = true;

        final String url = 'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report';
        final String? audioFilePath = await startRecording(Duration(minutes: 1));

        if (audioFilePath != null && audioFilePath.isNotEmpty) {
          try {
            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.headers['Authorization'] = 'Bearer $jwt'; // Include JWT token in the headers

            request.files.add(await http.MultipartFile.fromPath('file', audioFilePath));

            var response = await request.send();
            if (response.statusCode == 201) {
              print('Audio file sent successfully');
            } else {
              print('Failed to send audio file');
            }
          } catch (e) {
            print('Error sending audio file: $e');
          }
        } else {
          print('Failed to start audio recording');
        }

        _isRecording = false;
      } else {
        print('Audio recording is already in progress');
      }
    } else {
      print('JWT token is null. Make sure the user is authenticated.');
    }
  }

  Future<String?> startRecording(Duration duration) async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String audioFilePath = '${appDirectory.path}/recording.wav';

    try {
      await _audioRecorder.openRecorder();
      await _audioRecorder.startRecorder(
        codec: Codec.pcm16WAV,
        toFile: audioFilePath,
      );
      await Future.delayed(duration);
      String? result = await _audioRecorder.stopRecorder();
      await _audioRecorder.closeRecorder();
      return result != null ? audioFilePath : null;
    } catch (e) {
      print('Error starting audio recording: $e');
      return null;
    }
  }
}
