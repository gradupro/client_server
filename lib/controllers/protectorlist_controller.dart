import '/models/protector_model.dart';

class ProtectorListController {
  List<Protector> protectors = []; // List of protectors

  ProtectorListController() {
    protectors = [
      Protector(name: 'John Doe', phoneNumber: '1234567890'),
      Protector(name: 'Jane Smith', phoneNumber: '9876543210'),
    ];
  }

  Future<void> addProtector(Protector newProtector) async {
    // Simulate server request and verification process
    await Future.delayed(Duration(seconds: 2));

    // Add the new protector to the list
    protectors.add(newProtector);
  }
}
