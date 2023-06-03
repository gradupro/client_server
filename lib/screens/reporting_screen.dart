import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/trigger_controller.dart';

class ReportingScreen extends StatelessWidget {
  final String status;
  ReportingScreen({required this.status});
  static void navigateToReportingScreen() {
    Get.to(ReportingScreen(status: ''));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('신고 중'),
      ),
      body: Center(
        child: GetBuilder<TriggerController>(
          init: TriggerController(),
          builder: (controller) {
            String statusText = '';

            if (controller.isRecording) {
              statusText = 'Recording';
            } else if (controller.isTriggering) {
              statusText = 'Triggering';
            } else if (controller.isTriggerSent) {
              statusText = 'Sent Trigger to Server';
            }

            return Text(
              statusText,
              style: TextStyle(fontSize: 24),
            );
          },
        ),
      ),
    );
  }
}
