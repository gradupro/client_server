import 'package:flutter/material.dart';
import '/controllers/reportdetail_controller.dart';
import '/controllers/reportlist_controller.dart';
import 'reportdetail_screen.dart';

class ReportListScreen extends StatefulWidget {
  @override
  _ReportListScreenState createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final ReportListController _controller = ReportListController();
  int _currentIndex = 0;
  late ReportDetailController _reportDetailController;

  @override
  void initState() {
    super.initState();
    _controller.fetchReports(); // Fetch initial reports
    _reportDetailController = ReportDetailController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  void _navigateToReportDetail(BuildContext context, int reportId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReportDetailScreen(
                reportId: reportId, controller: _reportDetailController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고기록'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '신고 기록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.security),
                label: '보호 기록',
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Protector List'),
              onTap: () {
                Navigator.pushNamed(context, '/protectorlist_screen');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Report>>(
        stream: _controller.reportsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                final voice = report.voices.isNotEmpty
                    ? report.voices[0]
                    : null;
                return ListTile(
                  title: Text('${report.createdAt ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('상황: ${voice?.prediction?.combinedLabel ?? ''}'),
                      Text('내용: ${voice?.note ?? ''}'),
                      //Text('위치: '),
                      //Text('주소: '),
                    ],
                  ),
                  onTap: () {
                    _navigateToReportDetail(context, report.id);
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}