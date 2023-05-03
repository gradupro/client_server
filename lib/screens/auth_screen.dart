import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  final _phonenumberController = TextEditingController();
  final _fullnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    await Permission.location.request();
    await Permission.notification.request();
    await Permission.audio.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 120.0),
            TextField(
              controller: _phonenumberController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Phone number',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _fullnameController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Full name',
              ),
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  //
                  child: Text('인증번호 보내기'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}