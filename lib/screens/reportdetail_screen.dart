import 'package:flutter/material.dart';
import '/controllers/reportdetail_controller.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportDetailController controller;
  final int reportId;

  ReportDetailScreen({ required this.reportId, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('상세 신고'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle make a call button press
              },
              child: Text('Make a Call'),
            ),
            SizedBox(height: 16.0),
            Text(
              '신고 내용',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            FutureBuilder<String>(
              future: controller.fetchReportContent(), // Replace with your API call to fetch the report content
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final reportContent = snapshot.data ?? '';
                  return Text(reportContent);
                }
              },
            ),
            SizedBox(height: 16.0),
            Text(
              '신고음성',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            // Add audio player widget here
            SizedBox(height: 16.0),
            Text(
              '신고자 위치',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            FutureBuilder<String>(
             // future: controller.fetchReporterLocation(), // Replace with your API call to fetch the reporter location
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final reporterLocation = snapshot.data ?? '';
                  return Text(reporterLocation);
                }
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle "경찰에 신고하기" button press
              },
              child: Text('경찰에 신고하기'),
            ),
          ],
        ),
      ),
    );
  }
}
