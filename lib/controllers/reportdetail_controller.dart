import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportDetailController {
  Future<String> fetchReportContent() async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));
    // Replace with your API call logic to fetch the report content
    return 'Report content from server';
  }

//Future<String> fetchReporterLocation() async {
// Simulate API call delay
//await Future.delayed(Duration(seconds: 2));
// Replace with your API call logic
}
