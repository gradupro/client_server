import 'dart:async';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:rxdart/rxdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}

class OngoingReportController {
  late IO.Socket _socket;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  late StreamController<Location> _locationStreamController;

  Stream<Location> get locationStream => _locationStreamController.stream;

  OngoingReportController() {
    initSocketConnection();
  }

  Future<void> fetchReport(int reportId) async {
    String url = "http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report?id=$reportId";
    final String? jwt = await _secureStorage.read(key: 'jwt');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $jwt'},
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print(data);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void initSocketConnection() {
    _socket = IO.io('http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/socket.io');
    _locationStreamController = StreamController<Location>();
    _socket.on('chat', (data) {
      // Adjust data extraction according to the actual data structure
      List route = data['data']['message']['body']['route'][0];
      double latitude = route[1];
      double longitude = route[0];
      _locationStreamController.add(Location(latitude: latitude, longitude: longitude));
    });
  }

  void dispose() {
    _locationStreamController.close();
    _socket.disconnect();
  }
}
