import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorPageViewModel extends ChangeNotifier{

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
    double tempVal = 0;
    for(int i = 0; i < footArray.length; i++)
    {
      if(footArray[i] > tempVal)
      {
        tempVal = footArray[i];
      }
    }
  }
  /*
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
*/
  /// Updates the chart
  List<SplineSeries<Data, int>> getDataLeft() {
    notifyListeners();
    return <SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        dataSource: bleController.leftFoot!,
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
  List<SplineSeries<Data, int>> getDataRight(){
    notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        dataSource: bleController.rightFoot!,
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
