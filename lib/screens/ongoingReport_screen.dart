import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_audio/just_audio.dart';
import '/controllers/ongoingReport_controller.dart';
import '/controllers/IsInterrupt_controller.dart';

class DurationSlider extends StatelessWidget {
  final Duration? duration;
  final Duration? position;
  final ValueChanged<Duration> onChanged;

  DurationSlider({this.duration, this.position,required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: duration?.inMilliseconds.toDouble() ?? 1.0,
      value: position?.inMilliseconds.toDouble() ?? 0.0,
      onChanged: (value) {
        onChanged(Duration(milliseconds: value.toInt()));
      },
    );
  }
}

class OngoingReportScreen extends StatefulWidget {
  final OngoingReportController controller;
  final int reportId;

  OngoingReportScreen({required this.reportId, required this.controller});

  @override
  _OngoingReportScreenState createState() => _OngoingReportScreenState();
}

class _OngoingReportScreenState extends State<OngoingReportScreen> {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late AudioPlayer audioPlayer;
  Duration? duration;
  Duration? position;
  double volume = 0.5;
  Report? report;
  GoogleMapController? _googleMapController;
  late LatLng initialPos;
  late Stream<Location> locationStream;
  List<Location> _route = [];


  @override
  void initState() {
    super.initState();
    initialPos = LatLng(37.336636, 127.265709);
    locationStream = widget.controller.locationStream.asBroadcastStream();

    locationStream.listen((Location location) {
      setState(() {
        // Add the new location to the route.
        _route.add(location);

        // Convert the route (List<Location>) to a List<LatLng> for use with Marker and Polyline.
        final routePoints = _route.map((location) => LatLng(location.latitude, location.longitude)).toList();

        // Create markers (start and current) and polylines with the updated routePoints.
        _markers = _createMarkers(routePoints);
        _polylines = _createPolylines(routePoints);
      });

      // Move the camera to the new location.
      _googleMapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(location.latitude, location.longitude),
        ),
      );
    });


    widget.controller.fetchReport(widget.reportId).then((fetchedReport) {
      setState(() {
        report = fetchedReport;
        audioPlayer.setUrl(report!.originalSoundUrl);
      });
    });

    audioPlayer = AudioPlayer();

    audioPlayer.durationStream.listen((d) {
      setState(() {
        duration = d;
      });
    });

    audioPlayer.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });

    widget.controller.initSocketConnection(widget.reportId);
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    widget.controller.dispose();
    super.dispose();
  }

  Set<Marker> _createMarkers(List<LatLng> routePoints) {
    final startMarker = Marker(
      markerId: MarkerId('start'),
      position: routePoints.first,
      infoWindow: InfoWindow(
        title: 'Start',
        snippet: 'Lat: ${routePoints.first.latitude}, Long: ${routePoints.first.longitude}',
      ),
    );

    final currentMarker = Marker(
      markerId: MarkerId('current'),
      position: routePoints.last,
      infoWindow: InfoWindow(
        title: 'Current',
        snippet: 'Lat: ${routePoints.last.latitude}, Long: ${routePoints.last.longitude}',
      ),
    );

    return {startMarker, currentMarker};
  }


  Set<Polyline> _createPolylines(List<LatLng> routePoints) {
    final polyline = Polyline(
      polylineId: PolylineId('route'),
      visible: true,
      points: routePoints,
      color: Colors.red,
      width: 2,
    );

    return {polyline};
  }


  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('위급 상황 진행 중'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: report == null
            ? Center(
            child: CircularProgressIndicator()) // Show a loading spinner while report is null
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${report?.user.name}이(가) 위험합니다.',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _makePhoneCall('tel:${report?.user.phoneNumber}');
              },
              child: Text('${report?.user.name}에게 전화하기'),
            ),
            SizedBox(height: 16.0),
            Text(
              '신고 내용',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Text(
                    '상황 분류: ${report?.categoryList?.join(', ') ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '상황 비율: ${report?.categoriesRatio ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '유력 상황: ${report?.mostCategory ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    '신고 발생 시간: ${report?.createdAt ?? 'N/A'}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '신고음성',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            StreamBuilder<PlayerState>(
              stream: audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;

                if (processingState == ProcessingState.loading ||
                    processingState == ProcessingState.buffering) {
                  return Center(child: CircularProgressIndicator());
                } else if (playing != true) {
                  return IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: audioPlayer.play,
                  );
                } else if (processingState != ProcessingState.completed) {
                  return IconButton(
                    icon: Icon(Icons.pause),
                    onPressed: audioPlayer.pause,
                  );
                } else {
                  return IconButton(
                    icon: Icon(Icons.replay),
                    onPressed: () =>
                        audioPlayer.seek(
                          Duration.zero,
                          index: audioPlayer.effectiveIndices?.first,
                        ),
                  );
                }
              },
            ),
            DurationSlider(
              duration: duration,
              position: position,
              onChanged: (newPosition) {
                audioPlayer.seek(newPosition);
              },
            ),
            SizedBox(height: 16.0),
            Text(
              '신고자 위치',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 300,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _googleMapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: initialPos,
                  zoom: 15,
                ),
                markers: _markers,
                polylines: _polylines,
              ),
            ),

            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _makePhoneCall('tel:112');
              },
              child: Text('경찰에 신고하기'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                final IsInterruptController isInterruptController = IsInterruptController();
                await isInterruptController.IsInterrupted(widget.reportId);
              },
              child: Text('위급 상황 중단'),
            ),

          ],
        ),
      ),
    );
  }
}
