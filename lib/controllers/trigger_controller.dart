import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';


class TriggerController extends GetxController {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isRecording = false;
  bool _isTriggering = false;
  bool _isTriggerSent = false;
  late FlutterSoundRecorder _audioRecorder;
  bool isVolumeDownPressed = false;

  bool get isRecording => _isRecording;
  bool get isTriggering => _isTriggering;
  bool get isTriggerSent => _isTriggerSent;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

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
              if (magnitude > shakeThreshold ) {
                print('Shake event detected with volume down button pressed');
                triggerEvent();
              }
            });
          });
        }
      }
    });

    SystemChannels.keyEvent.setMessageHandler((message) async {
      if (message is Map<String, dynamic>) {
        if (message['event'] == 'keydown') {
          int? keyCode = message['keyCode'] as int?;
          if (keyCode == 25) {
            // Volume Down button's key code
            // Volume Down button is pressed
            isVolumeDownPressed = true;
          }
        } else if (message['event'] == 'keyup') {
          int? keyCode = message['keyCode'] as int?;
          if (keyCode == 25) {
            // Volume Down button's key code
            // Volume Down button is released
            isVolumeDownPressed = false;
          }
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
        _isRecording = true; // Update isRecording status
        update();

        final String url = 'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report';
        final String? audioFilePath = await startRecording(
            Duration(seconds: 10));

        if (audioFilePath != null && audioFilePath.isNotEmpty) {
          try {
            _isTriggering = true; // Update isTriggering status
            update();
            var request = http.MultipartRequest('POST', Uri.parse(url));
            request.headers['Authorization'] = 'Bearer $jwt';
            request.files.add(
                await http.MultipartFile.fromPath('file', audioFilePath));

            var response = await request.send();
            if (response.statusCode == 201) {
              _isTriggerSent = true; // Update isTriggerSent status
              update();
              print('Audio file sent successfully');

              // Extract the reportId from the response
              final reportId = extractReportIdFromResponse(await http.Response.fromStream(response));
              if (reportId != null) {
                print('Report ID: $reportId');
                // Call the createLocation function with the retrieved report ID and start location updates
                createLocation(int.parse(reportId));
                updateLocation(int.parse(reportId));
              } else {
                print('Failed to extract report ID from response');
              }
            } else {
              print('Failed to send audio file');
            }
          } catch (e) {
            print('Error sending audio file: $e');
          }
        } else {
          print('Failed to start audio recording');
        }

        _isRecording = false; // Update isRecording status
        _isTriggering = false; // Update isTriggering status
        update();

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
        toFile: audioFilePath,
        codec: Codec.pcm16WAV,
      );
      await Future.delayed(duration);
      await _audioRecorder.stopRecorder();
      await _audioRecorder.closeRecorder();
      return audioFilePath;
    } catch (e) {
      print('Error starting audio recording: $e');
      return null;
    }
  }

  Future<void> createLocation(int reportId) async {
    final Position position = await Geolocator.getCurrentPosition();
    final double latitude = position.latitude;
    final double longitude = position.longitude;
    final String? jwt = await _secureStorage.read(key: 'jwt');
    if (jwt != null) {
      final String url =
          'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/location';
      final Map<String, dynamic> payload = {
        'reportId': reportId,
        'payload': {
          'latitude': latitude,
          'longitude': longitude,
        },
      };
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        );
        if (response.statusCode == 201) {
          print('Location created successfully');
          print(reportId);
          print(reportId.runtimeType);
        } else {
          print('Failed to create location');
        }
      } catch (e) {
        print('Error creating location: $e');
      }
    } else {
      print('JWT token is null. Make sure the user is authenticated.');
    }
  }

  void updateLocation(int reportId) {
    Timer timer = Timer.periodic(Duration(seconds: 5), (Timer t) async {
      try {
        final Position position = await Geolocator.getCurrentPosition();
        final double latitude = position.latitude;
        final double longitude = position.longitude;
        final String? jwt = await _secureStorage.read(key: 'jwt');

        final String url = 'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/location';
        final Map<String, dynamic> payload = {
          'reportId': reportId,
          'payload': {
            'latitude': latitude,
            'longitude': longitude,
          },
        };
        final response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 403) {
          t.cancel();
        }

      } catch (e) {
        print('Error retrieving current position: $e');
      }
    });
  }


  String? extractReportIdFromResponse(http.Response response) {
    try {
      final jsonResponse = jsonDecode(response.body);
      final reportId = jsonResponse['data']['id'].toString();
      return reportId;
    } catch (e) {
      print('Error extracting report ID from response: $e');
      return null;
    }
  }
}