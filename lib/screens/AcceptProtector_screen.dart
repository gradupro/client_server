import 'package:flutter/material.dart';
import '/controllers/receiveNotiforProtector_controller.dart';

class ProtectorRequestScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Protector Request'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have received a protector request.',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Accept'),
              onPressed: () {
                acceptRequest(context);
              },
            ),
            ElevatedButton(
              child: Text('Decline'),
              onPressed: () {
                declineRequest(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void acceptRequest(BuildContext context) async {
    final bool accepted = await PushNotificationController.sendProtectorResponse(true);
    if (accepted) {
      // Display a success message or navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Protector request accepted.'),
      ));
    } else {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to accept protector request.'),
      ));
    }
  }

  void declineRequest(BuildContext context) async {
    final bool accepted = await PushNotificationController.sendProtectorResponse(false);
    if (accepted) {
      // Display a success message or navigate to the next screen
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Protector request declined.'),
      ));
    } else {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to decline protector request.'),
      ));
    }
  }
}
