import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';

import '../model/sensor.dart';
class DataScreen extends StatefulWidget {
  @override
  _DataState createState() => _DataState();
}

class _DataState extends State<DataScreen> {
  BLEController bleController = BLEController();
  SensorPageViewModel sensorPageVM = SensorPageViewModel();
  late TextEditingController controller;
  List <int> time = <int>[];
  String connectionText = "";
  String name = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
    bleController.addListener(updateDetails);
  }
  void updateDetails(){

    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body:SafeArea(child:
      SingleChildScrollView(
        child:Column(
          children: [
            SfCartesianChart(
              //crosshairBehavior: _crosshairBehavior,
              legend: Legend(isVisible: true),
              //zoomPanBehavior: _zoomPanBehavior,
              series: sensorPageVM.getDataLeft(),
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
            SfCartesianChart(
              //crosshairBehavior: _crosshairBehavior,
              legend: Legend(isVisible: true),
              //zoomPanBehavior: _zoomPanBehavior,
              series: sensorPageVM.getDataRight(),
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

            TextButton(
                onPressed: () async {
                  if(bleController.leftFoot.isEmpty &&
                      bleController.rightFoot.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please start a run")));
                  }else{
                    final name = await openDialog();
                    if(name == null || name.isEmpty) return;
                    setState(() => this.name = name);
                    addHistory();
                  }
                },
                child: const Icon(Icons.save)),

          ],
        ),
      ),
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
  void submit(){
    Navigator.of(context).pop(controller.text );
    controller.clear();
  }

  Future addHistory() async {
    try{
      List<LiveData> leftList = sensorPageVM.getChartDataLeft();
      List<LiveData> rightList = sensorPageVM.getChartDataRight();
      final history =  History(
        dateTime: DateTime.now(),
        name: name,
        leftData: jsonEncode(leftList),
        rightData: jsonEncode(rightList),
      );
      print('SUCCESS');
      await HistoryDatabase.instance.create(history);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
    }catch(error){
      print('Fail');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

}
