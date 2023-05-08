import 'package:flutter/material.dart';
import '/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController _loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 120.0),
            TextField(
              controller: _loginController.phoneNumberController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Phone Number',
              ),
            ),
            TextField(
              controller: _loginController.fullNameController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Full Name',
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: _loginController.login,
              child: Text('Log In'),
            ),
          ],
        ),
      ),
    );
  }
}