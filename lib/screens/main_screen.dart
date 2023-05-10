import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'protectlist_screen.dart';
import 'reportlist_screen.dart';
import '/controllers/main_controller.dart';

class MainScreen extends StatefulWidget {
  final MainController controller;

  MainScreen({required this.controller});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ReportListScreen(),
    ProtectListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    initializeDeviceToken();
  }

  Future<void> initializeDeviceToken() async {
    String? deviceToken = await widget.controller.getDeviceToken();
    if (deviceToken != null) {
      widget.controller.sendDeviceInfo(deviceToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '신고기록',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.security),
                label: '보호 목록',
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Protector List'),
              onTap: () {
                // Navigate to the Protector List screen
                Navigator.pushNamed(context, '/protectorlist_screen');
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
    );
  }
}
