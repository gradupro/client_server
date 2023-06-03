import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '/controllers/ongoingReport_controller.dart';
import 'dart:async';

class OngoingReportScreen extends StatefulWidget {
  final OngoingReportController controller;
  final int reportId;

  OngoingReportScreen({required this.reportId, required this.controller});

  @override
  _OngoingReportScreenState createState() => _OngoingReportScreenState();
}

class _OngoingReportScreenState extends State<OngoingReportScreen> {
  Set<Marker> _markers = Set<Marker>();

  @override
  void initState() {
    super.initState();
    widget.controller.locationStream.listen((Location location) {
      setState(() {
        // Add new marker for the updated location
        _markers = _createMarkers(location);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Set<Marker> _createMarkers(Location location) {
    final marker = Marker(
      markerId: MarkerId('reporterLocation'),
      position: LatLng(location.latitude, location.longitude),
      infoWindow: InfoWindow(
        title: '신고자 위치',
        snippet: '위도: ${location.latitude}, 경도: ${location.longitude}',
      ),
    );

    return Set<Marker>.from([marker]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위급 상황 진행 중'),
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
              //future: widget.controller.fetchReport(widget.reportId),
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
            Text('신고자 위치',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 300, // Set the desired height for the map
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(0, 0), // Default initial location
                  zoom: 15,
                ),
                markers: _markers,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Handle "경찰에 신고하기" button press
              },
              child: Text('경찰에 신고하기'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Handle "위급 상황 중단" button press
              },
              child: Text('위급 상황 중단'),
            ),
          ],
        ),
      ),
    );
  }
}
