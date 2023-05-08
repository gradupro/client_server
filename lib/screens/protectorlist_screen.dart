import 'package:flutter/material.dart';
import '/models/protector.dart'; // Replace with your protector model
import 'addprotector_screen.dart';

class ProtectorListScreen extends StatefulWidget {
  @override
  _ProtectorListScreenState createState() => _ProtectorListScreenState();
}

class _ProtectorListScreenState extends State<ProtectorListScreen> {
  List<Protector> protectors = []; // List of protectors

  @override
  void initState() {
    super.initState();
    // TODO: Fetch the list of protectors from your data source
    // For example, you can call an API or retrieve data from a database
    // and populate the 'protectors' list with the fetched data
    // For now, let's add some dummy protectors for testing
    protectors = [
      Protector(name: 'John Doe', phoneNumber: '1234567890'),
      Protector(name: 'Jane Smith', phoneNumber: '9876543210'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보호자 목록'),
      ),
      body: ListView.builder(
        itemCount: protectors.length,
        itemBuilder: (BuildContext context, int index) {
          Protector protector = protectors[index];
          return ListTile(
            title: Text(protector.name),
            subtitle: Text(protector.phoneNumber),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProtectorScreen()),
          ).then((newProtector) {
            if (newProtector != null) {
              setState(() {
                protectors.add(newProtector);
              });
            }
          });
        },
      ),
    );
  }
}
