import 'package:flutter/material.dart';
import '/controllers/protectorlist_controller.dart';
import '/models/protector_model.dart';
import 'addProtector_screen.dart';

class ProtectorListScreen extends StatefulWidget {
  @override
  _ProtectorListScreenState createState() => _ProtectorListScreenState();
}

class _ProtectorListScreenState extends State<ProtectorListScreen> {
  final ProtectorListController _controller = ProtectorListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보호자 목록'),
      ),
      body: ListView.builder(
        itemCount: _controller.protectors.length,
        itemBuilder: (BuildContext context, int index) {
          Protector protector = _controller.protectors[index];
          return ListTile(
            title: Text(protector.name),
            subtitle: Text(protector.phoneNumber),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Protector newProtector = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProtectorScreen()),
          );

          if (newProtector != null) {
            await _controller.addProtector(newProtector);
            setState(() {}); // Refresh the screen
          }
        },
      ),
    );
  }
}
