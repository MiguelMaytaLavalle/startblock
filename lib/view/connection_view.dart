import 'dart:async';
import 'dart:math';
import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter/material.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view/recording_view.dart';
import 'package:startblock/view/setting_view.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';

import '../helper/BLEController.dart';
import 'data_view.dart';

class ConnectionView extends StatefulWidget {
  @override
  _ConnectionState createState() => _ConnectionState();
}

class _ConnectionState extends State<ConnectionView> {
  BLEController bleController = BLEController();
  var sensorPageVM = SensorPageViewModel();
  late TextEditingController controller;
  String connectionText = "";
  String name = '';
  int _selectedIndex = 0;

  List<Widget> screens=<Widget>[
    RecordingScreen(), //Index 0
    DataScreen(), //Index 1
    SettingScreen(),//Index 2
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
    /*Column(
          children: [
            SizedBox(
                height: 500,
                child:  StreamBuilder<BluetoothDeviceState>(
                  stream: targetDevice?.state,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.active) {
                      return SafeArea(
                        child: Scaffold(
                          body: SfCartesianChart(
                            //crosshairBehavior: _crosshairBehavior,
                            legend: Legend(isVisible: true),
                            //zoomPanBehavior: _zoomPanBehavior,
                            series: _getUpdateSeries(),
                            primaryXAxis: NumericAxis(
                                interactiveTooltip: const InteractiveTooltip(
                                  enable: true,
                                ),
                                majorGridLines: const MajorGridLines(width: 0),
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                interval: 1000, //1000ms between two timestamps equals a second
                                title: AxisTitle(text: 'Time [S]')
                            ),

                            primaryYAxis: NumericAxis(
                                minimum: 0,
                                //maximum: 800,
                                interactiveTooltip: const InteractiveTooltip(
                                  enable: true,
                                ),
                                axisLine: const AxisLine(width: 0),
                                majorTickLines: const MajorTickLines(size: 0),
                                title: AxisTitle(text: 'Force [N]')
                            ),
                          ),
                        ),
                      );
                    } else { return const Text('Check the stream'); }
                  },
                )
            ),
            Wrap(
              direction: Axis.vertical,
              children: const <Widget>[
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Rate of force (RFD): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Time to peak (TTP): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Force impulse: 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Peak force: 0'
                    )
                ),
              ],
            ),
          ],
        ),*/
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
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
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
