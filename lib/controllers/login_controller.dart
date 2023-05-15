import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '/models/user_model.dart';
import '/screens/protectorlist_screen.dart';

class LoginController {
  final phoneNumberController = TextEditingController();
  final fullNameController = TextEditingController();

  final Dio dio = Dio();
  final GlobalKey<NavigatorState> navigatorKey;

  LoginController({required this.navigatorKey});

  void login() async {
    final phoneNumber = phoneNumberController.text;
    final fullName = fullNameController.text;

    try {
      User user = await getUserByPhoneNumberAndFullName(phoneNumber, fullName);

      if (user != null) {
        final response = await dio.post(
          'http://ecs-elb-1310785165.ap-northeast-2.elb.amazonaws.com/api/user/login',
          data: {
            'phone_Number': user.phoneNumber,
            'fullName': user.name,
            'JWT': user.JWT,
          },
        );

        // Navigate to the ProtectorListScreen
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => ProtectorListScreen(),
          ),
        );
      } else {
        print('User not found');
      }
    } catch (error) {
      print(error);
    }
  }

  User getUserByPhoneNumberAndFullName(String phoneNumber, String fullName) {
    List<User> users = [];

    User matchedUser = users.firstWhere(
          (user) =>
      user.phoneNumber == phoneNumber && user.name == fullName,
    );
    return matchedUser;
  }
}
