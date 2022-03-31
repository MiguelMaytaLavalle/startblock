import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constant/constants.dart';
import '../model/movesense.dart';
import '../model/timestamp.dart';

class DataViewViewModel extends ChangeNotifier{

  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  BLEController bleController = BLEController();

  late List<Data> tempLeft;
  late List<Data> tempRight;
  late List<Movesense> tempMovesenseData;

  double _peakForceLeft = 0;
  double _RFDLeft = 0;
  double _avgForceLeft = 0;
  double _totalForceLeft = 0;
  double _forceImpulseLeft = 0;
  int _timeToPeakForceLeft = 0;

  double _peakForceRight = 0;
  double _RFDRight = 0;
  double _avgForceRight = 0;
  double _totalForceRight = 0;
  double _forceImpulseRight = 0;
  int _timeToPeakForceRight = 0;

  DataViewViewModel()
  {
    tempLeft = bleController.leftFootEWMA;
    tempRight = bleController.rightFootEWMA;
  }
  ///Calculates the time to peak based on the array data since the
  ///ratio between sampled data array and time array is 1:1
  int getTimeToPeakForceLeft()
  {
    _timeToPeakForceLeft = _calcTimeToPeakForce(tempLeft);
    return _timeToPeakForceLeft;
  }
  int getTimeToPeakForceRight()
  {
    _timeToPeakForceRight =_calcTimeToPeakForce(tempRight);
    return _timeToPeakForceRight;
  }
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
  double getForceImpulseLeft()
  {
    _totalForceLeft = _calcTotalForce(tempLeft);
    if(_totalForceLeft.isNaN)
      {
        return 0;
      }
    else
      {
        _forceImpulseLeft = _calcForceImpulse(tempLeft, _totalForceLeft);
        return _forceImpulseLeft;
      }
  }
  double getForceImpulseRight()
  {
    _totalForceRight = _calcTotalForce(tempRight);
    if(_totalForceRight.isNaN)
      {
        return 0;
      }
    else
      {
        _forceImpulseRight = _calcForceImpulse(tempRight, _totalForceRight);
        return _forceImpulseRight;
      }
  }
  double getAverageForceLeft()
  {
    _totalForceLeft = _calcTotalForce(tempLeft);
    if(_totalForceLeft.isNaN)
      {
        return  0;
      }
    else
      {
        _avgForceLeft = _calcAverageForce(tempLeft, _totalForceLeft);
        return _avgForceLeft;
      }
  }
  double getAverageForceRight()
  {
    _totalForceRight = _calcTotalForce(tempRight);
    if(_totalForceRight.isNaN)
      {
        return 0;
      }
    else
    {
      _avgForceRight = _calcAverageForce(tempRight, _totalForceRight);
      return _avgForceRight;
    }
  }
  ///Calculates the area the for the dataset using Trapezoidal rule. AKA Integration
  double _calcTotalForce(List<Data> data)
  {
    double result = 0.0;
    //Calculates the area the for the dataset using Trapezoidal rule. AKA numerical integration
    for(int i = 0; i < data.length-1; i++)
    {
      if(data[i].getForce() >= Constants.MEAN_NOISE_THRESH)
      {
        var p = data[i].getTime();
        var q = data[i+1].getTime();
        result+=(q-p)/2*(data[i].getForce()+data[i+1].getForce());
      }
    }
    notifyListeners();
    return result;
  }
  ///Calculates the average force were noise can no longer be detected
  double _calcAverageForce(List<Data> data, double totalForce)
  {
    var tempT1;
    var tempT2;
    if(data.isEmpty)
      {
        return 0;
      }
    else
      {
        //Get time where noise stops from the beginning of the list
        for(int i = 0; i < data.length; i++)
        {
          if(data[i].getForce() >= Constants.MEAN_NOISE_THRESH)
          {
            tempT1 = data[i].getTime();
            break;
          }
        }
        //Get time where noise stops from the end of the list
        for(int i = data.length-1; i >= 0; i--)
        {
          if(data[i].getForce() >= Constants.MEAN_NOISE_THRESH)
          {
            tempT2 = data[i].getTime();
            break;
          }
        }
        return totalForce/(tempT2-tempT1);
      }
  }
  ///Calculates the force impulse where noise can no longer be detected
  double _calcForceImpulse(List<Data> data, double totalForce)
  {
    var tempT1;
    var tempT2;
    if(data.isEmpty)
    {
      return 0;
    }
  else
    {
      //Get time where noise stops from the beginning of the list
      for(int i = 0; i < data.length; i++)
      {
        if(data[i].getForce() >= Constants.MEAN_NOISE_THRESH)
        {
          tempT1 = data[i].getTime();
          break;
        }
      }
      //Get time where noise stops from the end of the list
      for(int i = data.length-1; i >= 0; i--)
      {
        if(data[i].getForce() >= Constants.MEAN_NOISE_THRESH)
        {
          tempT2 = data[i].getTime();
          break;
        }
      }
      return totalForce*(tempT2-tempT1);
    }
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
      tempVal = data[i].getForce()-data[i+1].getForce();
      if(slope < tempVal)
      {
        slope = tempVal;
      }
    }
    notifyListeners();
    return slope;
  }
  ///Gets raw value data to be saved persistently .
  List<LiveData> getLeftDataToSave (){
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
  ///Gets raw value data to be saved persistently.
  List<LiveData> getRightDataToSave (){
    List<LiveData> tmpRightList = <LiveData>[];
    for(int i = 0; i < bleController.rightFoot.length; i++){
      print("Right: ${bleController.rightFoot[i]}");
      tmpRightList.add(LiveData(
          force: bleController.rightFoot[i].mForce
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpRightList;
  }
  ///Gets time stamps from sample to be saved persistently.
  List<Timestamp> getTimestampsToSave(){
    List<Timestamp> tmpList = <Timestamp>[];
    for(int i = 0; i < bleController.timestamps.length; i++){
      print("Timestamp: ${bleController.timestamps[i]}");
      tmpList.add(Timestamp(
          time: bleController.timestamps[i].time
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpList;
  }

  /// Updates the chart if data is added to temp arrays.
  List<SplineSeries<Data, int>> getDataLeft(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.blue,
        //dataSource: tempLeft,
        dataSource: bleController.leftFootEWMA,
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
        //dataSource: tempRight,
        dataSource: bleController.rightFootEWMA,
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
    return bleController.marzulloTimeOffset;
  }
  /// Gets data from Movesense accelerometer to be saved persistently.
  List<LiveData> getImuDataToSave (){
    List<LiveData> tmpAccList = <LiveData>[];
    for(int i = 0; i < bleController.movesenseData.length; i++){
      print("Acc: ${bleController.movesenseData[i].mAcc}");
      tmpAccList.add(LiveData(
          force: bleController.movesenseData[i].mAcc
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpAccList;
  }
  ///Gets timestamps from Movesense sample to be saved persistently.
  List<Timestamp> getImuTimestampsToSave (){
    List<Timestamp> tmpTimestampList = <Timestamp>[];
    for(int i = 0; i < bleController.movesenseData.length; i++){
      print("IMU timestamp: ${bleController.movesenseData[i].timestamp}");
      tmpTimestampList.add(Timestamp(
          time: bleController.movesenseData[i].timestamp
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpTimestampList;
  }
  ///Gets timestamps for when Movesense data was received to be stored persistently.
  List<Timestamp> getMovesenseArriveTimestampsToSave (){
    List<Timestamp> tmpTimestampList = <Timestamp>[];
    for(int i = 0; i < bleController.movesenseData.length; i++){
      print("IMU timestamp: ${bleController.movesenseData[i].mobileTimestamp}");
      tmpTimestampList.add(Timestamp(
          time: bleController.movesenseData[i].mobileTimestamp
      ));
      print("Index: $i");
      print("-----------");
    }
    return tmpTimestampList;
  }
}
