import 'package:flutter/material.dart';
import '/models/protector_model.dart';
import '/controllers/addProtector_controller.dart';

class AddProtectorScreen extends StatelessWidget {
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Protector'),
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
              onPressed: () async {
                String phoneNumber = phoneNumberController.text.trim();
                if (phoneNumber.isNotEmpty) {
                  bool added = await AddProtectorController.addProtector(phoneNumber);
                  if (added) {
                    // Successfully added the protector
                    Protector newProtector = Protector(
                      name: '', // Set the name based on your requirements
                      phoneNumber: phoneNumber,
                    );

                    Navigator.pop(context, newProtector);
                  } else {
                    // Failed to add the protector, show an error message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Error'),
                          content: Text('Failed to add the protector. Please try again.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
