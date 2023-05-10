import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:rxdart/rxdart.dart';


class ReportListController {
  final ScrollController _scrollController = ScrollController();
  final BehaviorSubject<List<Report>> _reportsSubject =
  BehaviorSubject<List<Report>>();
  bool _isLoading = false;
  int _page = 1;

  ScrollController get scrollController => _scrollController;
  Stream<List<Report>> get reportsStream => _reportsSubject.stream;

  ReportListController() {
    _scrollController.addListener(_scrollListener); // Add scroll listener
    fetchReports(); // Fetch initial reports
  }

  void _scrollListener() {
    if (_scrollController.offset >=
        _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      // Reached the end of the list, load more reports
      fetchReports();
    }
  }

  Future<void> fetchReports() async {
    if (!_isLoading) {
      _isLoading = true;

      // Example API endpoint to fetch reports from the server
      final url = 'https://example.com/api/reports?page=$_page';

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<Report> fetchedReports = List<Report>.from(
            data.map((reportData) => Report.fromJson(reportData)),
          );

          _reportsSubject.add(fetchedReports);

          _page++;
        } else {
          throw Exception('Failed to fetch reports');
        }
      } catch (e) {
        _reportsSubject.addError(e);
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
