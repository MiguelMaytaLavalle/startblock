
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/timestamp.dart';

class DataViewViewModel extends ChangeNotifier{

  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  BLEController bleController = BLEController();
  late List<Data> tempLeft;
  late List<Data> tempRight;
  double _peakForceLeft = 0;
  double _RFDLeft = 0;
  double _avgForceLeft = 0;
  int _timeToPeakForceLeft = 0;
  double _peakForceRight = 0;
  double _RFDRight = 0;
  double _avgForceRight = 0;
  int _timeToPeakForceRight = 0;

  double _alpha = 0.0;

  set alpha(double value) {
    _alpha = value;
  }

  DataViewViewModel()
  {
    //tempLeft = _EWMAFilter(bleController.leftFoot);
    //tempRight = _EWMAFilter(bleController.rightFoot);
    tempLeft = bleController.leftFoot;
    tempRight = bleController.rightFoot;
  }
  void EWMAFilter(double alpha)
  {
    _EWMAFilter(bleController.leftFoot);
    _EWMAFilter(bleController.rightFoot);
    notifyListeners();
  }
  List<Data>_EWMAFilter(List<Data> data)
  {
    double alpha = 0.5;
    List<Data> tempList = [];
    for(int i = 0; i < data.length-1; i++)
    {
      if(i == 0)
      {
        tempList.add(data[i]);
      }
      else
      {
        Data tempData = data[i];
        tempData.mForce = alpha * data[i].getForce() + (1-alpha) * tempList[i-1].getForce();
        tempList.add(tempData);
      }
    }
    notifyListeners();
    return tempList;
  }
  ///Calculates the time to peak based on the array data since the
  ///ratio between sampled data array and time array is 1:1
  int _calcTimeToPeakForce(List<Data> data)
  {
    double tempVal = 0;
    int tempTime = 0;
    for(int i = 0; i < data.length; i++)
      {
        if(data[i].getForce() > tempVal)
          {
            tempVal = data[i].getForce();
            tempTime = data[i].getTime();
          }
      }
    notifyListeners();
    return tempTime;
  }
  ///Calculates the highest value in the array, AKA peak force
  double getPeakForceLeft()
  {
    _peakForceLeft = _calcPeakForce(tempLeft);
    return _peakForceLeft;
  }
  double getPeakForceRight()
  {
    _peakForceRight = _calcPeakForce(tempRight);
    return _peakForceRight;
  }
  double _calcPeakForce(List<Data> data)
  {
    double tempVal = 0;
    for(int i = 0; i < data.length; i++)
    {
      if(data[i].getForce() > tempVal)
      {
        tempVal = data[i].getForce();
      }
    }
    notifyListeners();
    return tempVal;
  }

  double getAverageForceLeft()
  {
    //var area = _calcGraphArea(tempLeft);
    _avgForceLeft = _calcAverageForce(0);
    return _avgForceLeft;
  }
  double getAverageForceRight()
  {
    //var area = _calcGraphArea(tempRight);
    _avgForceRight = _calcAverageForce(0);
    return _avgForceRight;
  }
  double _calcAverageForce(double area)
  {
    return 0;
  }
  ///Calculates the area the for the dataset using Trapezoidal rule. AKA Integration
  double _calcGraphArea(List<Data> data)
  {
    var result = 0.0;
    for(int i = 0; i < data.length-1; i++)
      {
        var p = data[i].getTime();
        var q = data[i+1].getTime();
        result+=(q-p)/2*(data[i].getForce()+data[i+1].getForce());
      }
    notifyListeners();
    return result;
  }
  ///Calculates the slope of the plotted function. Slope value represents Rate of Force Development
  double getRFDLeft()
  {
    _RFDLeft = _calcRFD(tempLeft);
    return _RFDLeft;
  }
  double getRFDRight()
  {
    _RFDRight = _calcRFD(tempRight);
    return _RFDRight;
  }
  double _calcRFD(List<Data> data)
  {
    var slope = 0.0;
    var tempVal = 0.0;
    for(int i = 0; i < data.length-1; i++)
    {
      tempVal = sqrt((data[i].getForce()-data[i+1].getForce()).abs());
      if(slope < tempVal)
        {
          slope = tempVal;
        }
    }
    notifyListeners();
    return slope;
  }
  List<LiveData> getChartDataLeft (){
    List<LiveData> tmpLeftList = <LiveData>[];
    for(int i = 0; i < bleController.leftFoot.length; i++){
      print("Left: ${bleController.leftFoot[i]}");
      tmpLeftList.add(LiveData(
        force: bleController.leftFoot[i].mForce
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpLeftList;
  }

  List<LiveData> getChartDataRight (){
    List<LiveData> tmpRightList = <LiveData>[];
    for(int i = 0; i < bleController.rightFoot.length; i++){
      print("Left: ${bleController.rightFoot[i]}");
      tmpRightList.add(LiveData(
          force: bleController.rightFoot[i].mForce
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpRightList;
  }

  List<Timestamp> getChartDataTimestamps(){
    List<Timestamp> tmpList = <Timestamp>[];
    for(int i = 0; i < bleController.timestamps.length; i++){
      print("Left: ${bleController.timestamps[i]}");
      tmpList.add(Timestamp(
          time: bleController.timestamps[i].time
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpList;
  }

  /// Updates the chart
  List<SplineSeries<Data, int>> getDataLeft(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.blue,
        dataSource: tempLeft,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.timestamp,
        yValueMapper: (Data data, _) => data.getForce(),
      ),
    ];
  }

  List<SplineSeries<Data, int>> getDataRight(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.red,
        dataSource: tempRight,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.timestamp,
        yValueMapper: (Data data, _) => data.mForce,
      ),
    ];
  }

  num getMarzullo() {
    return bleController.marzullo;
  }

}
