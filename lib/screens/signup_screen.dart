import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _phonenumberController = TextEditingController();
  final _varificationnumberController = TextEditingController();

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
            SizedBox(height: 12.0),
            TextField(
              controller: _varificationnumberController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'varification number',
              ),
              obscureText: true,
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton(
                  // 확인을 통해서 전화번호와 인증번호가 맞는지
                  child: Text('확인'),
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