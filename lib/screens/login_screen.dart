import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _phonenumberController = TextEditingController();
  final _fullnameController = TextEditingController();

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
                labelText: 'phone number',
              ),
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  // 인증번호 보내는 로직 필요
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