import 'package:flutter/material.dart';
import '/controllers/reportdetail_controller.dart';
import '/controllers/reportlist_controller.dart';
import 'reportdetail_screen.dart';

class ProtectListScreen extends StatefulWidget {
  @override
  _ProtectListScreenState createState() => _ProtectListScreenState();
}

class _ProtectListScreenState extends State<ProtectListScreen> {
  final ReportListController _controller = ReportListController();
  int _currentIndex = 0;
  late ReportDetailController _reportDetailController;

  @override
  void initState() {
    super.initState();
    _controller.fetchReports();// Fetch initial reports
    _reportDetailController  = ReportDetailController();
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
        builder: (context) => ReportDetailScreen(reportId: reportId, controller: _reportDetailController),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보호기록'),
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
                label: '보호 목록',
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
      body: StreamBuilder<List<dynamic>>(
        stream: _controller.reportsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text(report.title),
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