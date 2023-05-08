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
            TextField(
              controller: _loginController.verificationController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Verification Number',
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _loginController.sendVerification,
              child: Text('Send Verification'),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: _loginController.signIn,
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
