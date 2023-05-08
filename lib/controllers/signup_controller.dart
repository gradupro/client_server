import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class SignUpController {
  final phoneNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final verificationController = TextEditingController();

  final dio = Dio();

  void sendVerification() async {
    final phoneNumber = phoneNumberController.text;
    final fullName = fullNameController.text;

    try {
      final response = await dio.post(
        'https://your-node-js-server/send-verification',
        data: {
          'phoneNumber': phoneNumber,
          'fullName': fullName,
          'deviceToken': 'device_token_here',
        },
      );
      print(response.data);
    } catch (error) {
      print(error);
    }
  }

  void signUp() async {
    final phoneNumber = phoneNumberController.text;
    final fullName = fullNameController.text;
    final verificationNumber = verificationController.text;

    try {
      final response = await dio.post(
        'https://your-node-js-server/send-verification',
        data: {
          'phoneNumber': phoneNumber,
          'fullName': fullName,
          'verificationNumber': verificationNumber,
        },
      );
      print(response.data);
    } catch (error) {
      print(error);
    }
  }
}
