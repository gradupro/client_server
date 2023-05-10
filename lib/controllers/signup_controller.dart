import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class SignUpController {
  final phoneNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final verificationController = TextEditingController();

  final dio = Dio();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // 인증번호 보내기
  void sendVerification() async {
    final phoneNumber = phoneNumberController.text;

    try {
      final response = await dio.post(
        'https://certified-lots-mic-devices.trycloudflare.com/auth/SMS',
        data: {
          'phone_number': phoneNumber,
        },
      );
      print(response.data);
    } catch (error) {
      print(error);
    }
  }

  // 인증번호 확인
  void verifycode() async {
    final phoneNumber = phoneNumberController.text;
    final verificationNumber = verificationController.text;

    try {
      final response = await dio.post(
        'https://certified-lots-mic-devices.trycloudflare.com/auth/code',
        data: {
          'phone_number': phoneNumber,
          'code': verificationNumber,
        },
      );
      if (response.statusCode == 202) {
        print("verified"); // 여기가 유저에게도 보이게 팝업 형식으로 보여줘야함.
      } else {
        print("not verified");
      }
    }catch (error) {
      print(error);
    }
  }

  // 이름, 번호를 서버로 보내서 JWT받아오기.
  Future<void> signup(VoidCallback onSignUpComplete, BuildContext context) async {
    final phoneNumber = phoneNumberController.text;
    final fullName = fullNameController.text;

    // Initialize Firebase Messaging
    //FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    //String? deviceToken = await _firebaseMessaging.getToken();
    //print('Device Token: $deviceToken');

    try {
      final response = await dio.post(
        'https://certified-lots-mic-devices.trycloudflare.com/user/signup',
        data: {
          'phone_number': phoneNumber,
          'name': fullName,
        },
      );

      if (response.statusCode == 201) {
        // Parse the response JSON
        final data = json.decode(response.data.toString());
        print(data);
        final jwt = data['data']['accessToken'];
        print(jwt);

        // Update the user model
        User user = User(
          name: fullName,
          phoneNumber: phoneNumber,
          JWT: jwt,
        );

        // Store the JWT securely
        await _storeJWT(jwt);

        // Call the onSignUpComplete callback
        onSignUpComplete();

        // Navigate to the login screen
        Navigator.pushReplacementNamed(context, '/main_screen');
      } else {
        print('Signup failed');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> _storeJWT(String jwt) async {
    await _secureStorage.write(key: 'jwt', value: jwt);
  }

  Future<String?> _getJWT() async {
    return await _secureStorage.read(key: 'jwt');
  }
}