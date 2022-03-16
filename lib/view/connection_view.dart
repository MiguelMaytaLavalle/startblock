import 'dart:async';
import 'dart:math';
import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view/recording_view.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    MicrobitScreen(), //Index 0
    DataScreen() //Index 1
  ];
  @override
  void initState() {
    super.initState();
    bleController.startScan();
  }


  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      );
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Name'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter Name Here'),
        controller: controller,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          child: const Text('Submit'),
          onPressed: submit,
        ),
      ],
    ),
  );

  /// Bottom NavBar on tap action
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      /*
      switch(index){
        case 0:Navigator.of(context).push(MaterialPageRoute<Null>(builder: (BuildContext context) {
          return MicrobitScreen();
        }));
      }*/
    });
  }
  void submit(){
    Navigator.of(context).pop(controller.text );
    controller.clear();
  }

  Future addHistory() async {
      try{
        List<LiveData> leftList = sensorPageVM.getLeftChartData();
        List<LiveData> rightList = sensorPageVM.getRightChartData();
        final history =  History(
          dateTime: DateTime.now(),
          name: this.name,
          leftData: jsonEncode(leftList),
          rightData: jsonEncode(rightList),
        );
        await HistoryDatabase.instance.create(history);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
      }catch(error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
  }
/*
  void testUpdateSetState() {

    List<LiveData> tmpLeft = _getChartDataLeft();
    sensorPageVM.setLeftChartData(_getChartDataLeft());
    sensorPageVM.setRightChartData(_getChartDataRight());
    setState(() {
      bleController.isNotStarted = true;
    });
    print('Left length: ${sensorPageVM.getLeftChartData().length}');
    print('Right length: ${sensorPageVM.getRightChartData().length}');

  }

  List<LiveData> _getChartDataLeft (){
    List<LiveData> tmpLeftList = <LiveData>[];
    for(int i = 0; i < sensorPageVM.getLeftFootArray().length; i++){
      print("Left: ${sensorPageVM.getLeftFootArray()[i]}");
      tmpLeftList.add(LiveData(
          time: time[i],
          force: sensorPageVM.getLeftFootArray()[i]));
      print("Index: $i");
      print("-----------");
    }
    return tmpLeftList;
  }

  List<LiveData> _getChartDataRight (){
    List<LiveData> tmpRightList = <LiveData>[];
    for(int i = 0; i < sensorPageVM.getRightFootArray().length; i++){
      print("Right: ${sensorPageVM.getRightFootArray()[i]}");
      tmpRightList.add(LiveData(
          time: time[i],
          force: sensorPageVM.getRightFootArray()[i]));
      print("Index: $i");
      print("-----------");
    }
    return tmpRightList;
  }

  /// Updates the chart
  List<SplineSeries<LiveData, int>> _getUpdateSeries() {
    return <SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        dataSource: sensorPageVM.getLeftChartData()!,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
      SplineSeries<LiveData, int>(
        dataSource: sensorPageVM.getRightChartData()!,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
    ];
  }
 */
}
