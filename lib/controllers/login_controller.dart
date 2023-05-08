import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class LoginController {
  final phoneNumberController = TextEditingController();
  final fullNameController = TextEditingController();

  final dio = Dio();

  void login() async {
    try {
      final response = await dio.post(
        'https://your-node-js-server/login',
        data: {
          'phoneNumber': phoneNumberController.text,
          'fullName': fullNameController.text,
        },
      );

      // Handle the login response
      if (response.statusCode == 200) {
        final token = response.data['token'];
        // Store the token securely on the client-side (e.g., using Flutter Secure Storage)
        // Example: await secureStorage.write(key: 'token', value: token);
        print('Logged in successfully');
        print('Token: $token');
      } else {
        print('Login failed');
      }
    } catch (error) {
      print(error);
    }
  }
}