import 'package:flutter/material.dart';
import 'package:startblock/view/recording_view.dart';
import 'package:startblock/view/setting_view.dart';

import '../helper/BLEController.dart';
import 'data_view.dart';

/***
 * ConnectionView contains the bottomnavigation bar which
 * a user can navigate to three different views when connected to the micro:bit:
 * RecordingScreen
 * DataScreen
 * SettingScreen
 */

class ConnectionView extends StatefulWidget {
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<ConnectionView> {
  BLEController bleController = BLEController();
  int _selectedIndex = 0;

  List<Widget> screens=<Widget>[
    RecordingScreen(),
    DataScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    bleController.addListener(updateDetails);
    bleController.startScan();
  }
  void updateDetails(){

    if(mounted){
      setState((){});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${bleController.targetDevice?.name}"),
      ),
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.fiber_new),
              label: 'Record',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_graph_rounded),
              label: 'View Data',
            ),
/*            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),*/
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
  }
  /// Bottom NavBar on tap action
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
