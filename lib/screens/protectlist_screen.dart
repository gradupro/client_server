import 'package:flutter/material.dart';
import '../controllers/protectlist_controller.dart';
import '/controllers/reportdetail_controller.dart';
import '/controllers/ongoingReport_controller.dart';
import '/controllers/InterruptionCheck_controller.dart';
import 'ongoingReport_screen.dart';
import 'reportdetail_screen.dart';

class ProtectListScreen extends StatefulWidget {
  @override
  _ProtectListScreenState createState() => _ProtectListScreenState();
}

class _ProtectListScreenState extends State<ProtectListScreen> {
  final ProtectListController _controller = ProtectListController();
  int _currentIndex = 1;
  late ReportDetailController _reportDetailController;
  late OngoingReportController _ongoingReportController;
  late InterruptionCheckController _interruptioncheckController;

  @override
  void initState() {
    super.initState();
    _controller.fetchReports(); // Fetch initial reports
    _reportDetailController = ReportDetailController();
    _ongoingReportController = OngoingReportController();
    _interruptioncheckController = InterruptionCheckController();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller
    super.dispose();
  }

  void _navigateToReportScreen(BuildContext context, int reportId) async {
    bool InterruptionCheck = await _interruptioncheckController.checkInterruption(reportId); // Assuming checkInterruption() returns a boolean indicating interruption status

    if (InterruptionCheck) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReportDetailScreen(
                reportId: reportId,
                controller: _reportDetailController,
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OngoingReportScreen(
                reportId: reportId,
                controller: _ongoingReportController,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Report>>(
        stream: _controller.reportsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ListTile(
                  title: Text('${report.createdAt ?? ''}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('신고자: '),
                      Text('신고자 번호: '),
                      Text('상황: ${report.categoryList.join(', ')}'),
                      //Text('위치: '),
                      //Text('주소: '),
                    ],
                  ),
                  onTap: () {
                    _navigateToReportScreen(context, report.id);
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