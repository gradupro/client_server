import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReportListController {
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<List<Report>> _reportsSubject =
  BehaviorSubject<List<Report>>();
  bool _isLoading = false;
  int _id = 1;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  ScrollController get scrollController => _scrollController;
  Stream<List<Report>> get reportsStream => _reportsSubject.stream;

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
          'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/report/request';

      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $jwt'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          if (data != null && data is Map<String, dynamic>) {
            final List<Report> fetchedReports = [];

            if (data.containsKey('data') && data['data'] is List<dynamic>) {
              final List<dynamic> reportDataList = data['data'];

              for (var reportData in reportDataList) {
                if (reportData is Map<String, dynamic>) {
                  fetchedReports.add(Report.fromJson(reportData));
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
          throw Exception('Failed to fetch reports');
        }
      } catch (e) {
        if (!_reportsSubject.isClosed) {
          _reportsSubject.addError('Failed to fetch reports: $e');
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

class Voice {
  final String note;
  final Prediction prediction;

  Voice({
    required this.note,
    required this.prediction,
  });

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      note: json['note'],
      prediction: Prediction.fromJson(json['prediction']),
    );
  }
}

class Prediction {
  final String combinedLabel;

  Prediction({
    required this.combinedLabel,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      combinedLabel: json['combined_label'],
    );
  }
}

class Report {
  final int id;
  final String category;
  final String createdAt;
  final List<Voice> voices;

  Report({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.voices,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final List<Voice> voicesList = [];
    final voicesData = json['voices'] as List<dynamic>;

    voicesData.forEach((voiceData) {
      voicesList.add(Voice.fromJson(voiceData));
    });

    return Report(
      id: json['id'],
      category: json['category'],
      createdAt: json['created_at'],
      voices: voicesList,
    );
  }
}