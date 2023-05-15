import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rxdart/rxdart.dart';

class ReportListController {
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<List<Report>> _reportsSubject =
  BehaviorSubject<List<Report>>();
  bool _isLoading = false;
  int _id = 1;

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

      final url =
          'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/reports?id=$_id';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<Report> fetchedReports = List<Report>.from(
            data.map((reportData) => Report.fromJson(reportData)),
          );

          if (!_reportsSubject.isClosed) {
            _reportsSubject.add(fetchedReports);
          }

          _id++;
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

class Report {
  final int id;
  final String title;

  Report({
    required this.id,
    required this.title,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
    );
  }
}
