import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class OngoingReportController {
  late IO.Socket _socket;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  StreamController<Location> _locationStreamController = StreamController<Location>();

  Stream<Location> get locationStream => _locationStreamController.stream;

  Future<Report?> fetchReport(int reportId) async {
    String url = "http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report?id=$reportId";
    final String? jwt = await _secureStorage.read(key: 'jwt');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $jwt'},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        Report reportData = Report.fromJson(data['data']);
        print(reportData);
        return reportData; // returning the parsed data.
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null; // return null if there is an error.
  }

  void initSocketConnection(int reportId) {
    print(reportId);
    print("connection trying.");
    _socket = IO.io('http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    _socket.connect();
    _socket.on('connect', (_) => print('connect: ${_socket.id}'));
    _socket.emit('join_room', {'reportId': reportId, 'userId': 100000});

    _socket.on('chat', (data) {
      print('Data received: $data');
      if (data != null && data['body'] != null && data['body']['route'] != null) {
        List<dynamic> routeList = data['body']['route'];
        for (var route in routeList) {
          if (route is List<dynamic>) {
            List<double> coordinates = route.cast<double>();
            double longitude = coordinates[0];
            double latitude = coordinates[1];
            print('Location received: Latitude - $latitude, Longitude - $longitude');
            _locationStreamController.add(Location(latitude: latitude, longitude: longitude));
          }
        }
      } else {
        print('Received data does not contain expected structure.');
      }
    });
  }

  void dispose() {
    _locationStreamController.close();
    _socket.disconnect();
  }
}

class Report {
  final int id;
  final String createdAt;
  final User user;
  final List<String> categoryList;
  final Map<String, dynamic> categoriesRatio;
  final String mostCategory;
  final String originalSoundUrl;

  Report({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.categoryList,
    required this.categoriesRatio,
    required this.mostCategory,
    required this.originalSoundUrl,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final categoryListJson = json['categories']['categoryList'] as List<dynamic>;
    final categoriesRatioJson = json['categories']['categoriesRatio'] as Map<String, dynamic>;

    return Report(
      id: json['id'],
      createdAt: json['created_at'],
      user: User.fromJson(userJson),
      categoryList: List<String>.from(categoryListJson),
      categoriesRatio: categoriesRatioJson,
      mostCategory: json['categories']['mostCategory'],
      originalSoundUrl: json['original_sound_url'],
    );
  }
}

class User {
  final String name;
  final String phoneNumber;

  User({
    required this.name,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      phoneNumber: json['phone_number'],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}
