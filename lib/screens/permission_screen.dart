import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatelessWidget {
  final VoidCallback onPermissionGranted;

  const PermissionScreen({required this.onPermissionGranted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Permission Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please grant the required permissions',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              child: Text('Grant Permissions'),
              onPressed: () {
                Permission.location.request().then((status) {
                  if (status.isGranted) {
                    onPermissionGranted();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}


