
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DataViewViewMode extends ChangeNotifier{

  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  BLEController bleController = BLEController();
  ///Clears arrays that contains data.
  ///Converts micro:bit runtime to user friendly time
  convertRuntime(List<int> time)
  {
    var diff = time[0];
    List<int> temp = [];
    for(int i = 0; i < time.length; i++)
      {
        temp.add(time[i]-diff);
      }
  }
  ///Calculates the time to peak based on the array data since the
  ///ratio between sampled data array and time array is 1:1
  calcTimeToPeakForce(List<double> footArray, List<int> time)
  {
    notifyListeners();
    double tempVal = 0;
    int tempTime = 0;
    for(int i = 0; i < footArray.length; i++)
      {
        if(footArray[i] > tempVal)
          {
            tempVal = footArray[i];
            tempTime = time[i];
          }
      }
    return tempTime;
  }
  ///Calculates the highest value in the array, AKA peak force
  calcPeakForce(List<double> footArray)
  {
    notifyListeners();
    double tempVal = 0;
    for(int i = 0; i < footArray.length; i++)
    {
      if(footArray[i] > tempVal)
      {
        tempVal = footArray[i];
      }
    }
    return tempVal;
  }

  List<LiveData> getChartDataLeft (){
    List<LiveData> tmpLeftList = <LiveData>[];
    //for(int i = 0; i < sensorPageVM.getLeftFootArray().length; i++){
    for(int i = 0; i < bleController.leftFoot.length; i++){
      print("Left: ${bleController.leftFoot[i]}");
      tmpLeftList.add(LiveData(
          //time: time[i],
          time: bleController.leftFoot[i].timestamp,
          //force: sensorPageVM.getLeftFootArray()[i]
        force: bleController.leftFoot[i].mForce
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpLeftList;
  }

  List<LiveData> getChartDataRight (){
    List<LiveData> tmpRightList = <LiveData>[];
    //for(int i = 0; i < sensorPageVM.getRightFootArray().length; i++){
    for(int i = 0; i < bleController.rightFoot.length; i++){
      //print("Right: ${sensorPageVM.getRightFootArray()[i]}");
      print("Left: ${bleController.rightFoot[i]}");
      tmpRightList.add(LiveData(
          //time: time[i],
          time: bleController.rightFoot[i].timestamp,
          //force: sensorPageVM.getRightFootArray()[i]
          force: bleController.rightFoot[i].mForce
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpRightList;
  }

  /// Updates the chart
  List<SplineSeries<Data, double>> getDataLeft(){
    //notifyListeners();
    return<SplineSeries<Data, double>>[
      SplineSeries<Data, double>(
        color: Colors.blue,
        dataSource: bleController.leftFoot,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.getTime(),
        yValueMapper: (Data data, _) => data.getForce(),
      ),
    ];
  }

  List<SplineSeries<Data, double>> getDataRight(){
    //notifyListeners();
    return<SplineSeries<Data, double>>[
      SplineSeries<Data, double>(
        color: Colors.red,
        dataSource: bleController.rightFoot,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.getTime(),
        yValueMapper: (Data data, _) => data.getForce(),
      ),
    ];
  }

}
