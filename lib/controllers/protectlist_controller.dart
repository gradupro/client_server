import 'package:emerdy_client/controllers/reportlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class ProtectListController {
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<List<Reports>> _reportsSubject =
  BehaviorSubject<List<Reports>>();
  bool _isLoading = false;
  int _id = 1;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  ScrollController get scrollController => _scrollController;
  Stream<List<Reports>> get reportsStream => _reportsSubject.stream;

  ReportListController() {
    _scrollController.addListener(_scrollListener);
    fetchReports();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchReports();
    }
  }

  Future<void> fetchReports() async {
    if (!_isLoading) {
      _isLoading = true;
      final String? jwt = await _secureStorage.read(key: 'jwt');
      final url =
          'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report/protect';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $jwt'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data != null && data is Map<String, dynamic>) {
            final List<Reports> fetchedReports = [];
            if (data.containsKey('data') && data['data'] is List<dynamic>) {
              final List<dynamic> reportDataList = data['data'];
              for (var reportData in reportDataList) {
                if (reportData is Map<String, dynamic>) {
                  fetchedReports.add(Reports.fromJson(reportData));
                }
              }
            }
            if (!_reportsSubject.isClosed) {
              _reportsSubject.add(fetchedReports);
            }
            _id++;
          } else {
            throw Exception('Invalid data format');
          }
        } else {
          throw Exception(
              'Failed to fetch reports. Status code: ${response.statusCode}');
        }
      } catch (e) {
        if (!_reportsSubject.isClosed) {
          String errorMessage = 'Failed to fetch reports';
          if (e != null) {
            errorMessage += ': $e';
          }
          _reportsSubject.addError(errorMessage);
        }
      } finally {
        _isLoading = false;
      }
    }
  }

  void dispose() {
    _scrollController.dispose();
    _reportsSubject.close();
  }
}

class Report {
  final int id;
  final String createdAt;
  final User user;
  final List<String> categoryList;

  Report({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.categoryList,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>;
    final categoryListJson = json['categories']['categoryList'] as List<dynamic>;

    return Report(
      id: json['id'],
      createdAt: json['created_at'],
      user: User.fromJson(userJson),
      categoryList: List<String>.from(categoryListJson),
    );
  }
}

class User {
  final int id;
  final String name;
  final String phoneNumber;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'],
    );
  }
}