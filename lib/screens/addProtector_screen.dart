import 'package:flutter/material.dart';
import '/models/protector.dart'; // Replace with your protector model

class AddProtectorScreen extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보호자 추가하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Add'),
              onPressed: () {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  // Create a new Protector object with the entered phone number
                  Protector newProtector = Protector(
                    name: '', // Set the name based on your requirements
                    phoneNumber: phoneNumber,
                  );

                  // Pass the new protector back to the previous screen
                  Navigator.pop(context, newProtector);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
