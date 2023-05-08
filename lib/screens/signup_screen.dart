import 'package:flutter/material.dart';
import '/controllers/signup_controller.dart';
import 'package:dio/dio.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignUpComplete;

  SignUpScreen({required this.onSignUpComplete});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController _signUpController = SignUpController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 120.0),
            TextField(
              controller: _signUpController.phoneNumberController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'phone number',
              ),
            ),
            SizedBox(height: 120.0),
            TextField(
              controller: _signUpController.fullNameController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'full name',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _signUpController.verificationController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'verification number',
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _signUpController.sendVerification,
              child: Text('Send Verification'),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () {
                _signUpController.signUp();
                widget.onSignUpComplete(); // Call the onSignUpComplete callback
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}

