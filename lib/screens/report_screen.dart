import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/routing_push_to_report.dart';

// Push Notification 을 터치했을 때 이동할 페이지
class NotificationDetailsPage
    extends GetView<reportscreenController> {
  const NotificationDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(reportscreenController());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'payload: ',
              style: TextStyle(fontSize: 20),
            ),
            Obx(() => Text(controller.argument.value)),
          ],
        ),
      ),
    );
  }
}