import 'package:flutter/material.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/forceData.dart';
import '../model/timestamp.dart';
import '../constant/constants.dart';

class HistoryCardViewModel{
  String hCardTitle = 'Test';
  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  late List<Data> leftChartData = <Data>[];
  late List<Data> rightChartData = <Data>[];
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
  var hCardModel = HistoryCardModel();

  getHistory(){
    return hCardModel.history;
  }

  getHistoryId(){
    return hCardModel.history.id;
  }

  getDateTime(){
    return hCardModel.history.dateTime;
  }

  getHistoryName(){
    return hCardModel.history.name;
  }

  setHistory(History hist){
    hCardModel.history = hist;
  }

  getRightLiveData(){
    return hCardModel.rightData;
  }

  setRightHistory(List<LiveData> list){
    hCardModel.rightData = list;
  }

  setMarzulloHistory(num m){
    hCardModel.marzullo = m;
  }

  getLeftLiveData(){
    return hCardModel.leftData;
  }

  setLeftHistory(List<LiveData> list){
    hCardModel.leftData = list;
  }

  setTimestampsHistory(List<Timestamp> list){
    hCardModel.timestamps = list;
  }

  getTimestamps(){
    return hCardModel.timestamps;
  }

  getIsLoading(){
    return hCardModel.isLoading;
  }

  setIsLoading(bool i){
    hCardModel.isLoading = i;
  }

  getHCardModel(){
    return hCardModel;
  }

  getMarzullo(){
    return hCardModel.history.marzullo;
  }

  getMarzulloCreationTime(){
    return hCardModel.history.marzulloCreationTime;
  }

  setMarzulloCreationTime(num m){
    hCardModel.marzulloCreationTime = m;
  }

  getLastServerTime(){
    return hCardModel.history.lastServerTime;
  }

  setLastServerTime(num m){
    hCardModel.lastServerTime = m;
  }

  getStartSampleTime(){
    return hCardModel.history.startSampleTime;
  }

  setStartSampleTime(num m){
    hCardModel.startSampleTime = m;
  }

  getStopSampleTime(){
    return hCardModel.history.stopSampleTime;
  }

  setStopSampleTime(num m){
    hCardModel.stopSampleTime = m;
  }

  setImuData(List<LiveData> list){
    hCardModel.imuData = list;
  }

  getImuData(){
    return hCardModel.imuData;
  }

  setImuTimestamps(List<Timestamp> list){
    hCardModel.imuTimestamps = list;
  }

  getImuTimestamps(){
    return hCardModel.imuTimestamps;
  }

  setTimestampArrival(List<Timestamp> list){
    hCardModel.imuTimestamps = list;
  }

  getTimestampArrival(){
    return hCardModel.timestampArrival;
  }

  setMovesenseArriveTime(List<Timestamp> list){
    hCardModel.movesenseArriveTime = list;
  }

  getMovesenseArriveTime(){
    return hCardModel.movesenseArriveTime;
  }
  ///Gets raw data that is stored persistently and applies EWMA-filter to temporary data.
  ///Alpha value can be changed in file Constants.dart
  void setupRightChartData(){
    for(int i = 0; i < getRightLiveData().length-1; i++){
      if(i == 0)
      {
        rightChartData.add(Data(getTimestamps()[i].time,getRightLiveData()[i].force));
      }
      else
      {
        Data tempData = Data(getTimestamps()[i].time,getRightLiveData()[i].force);
        tempData.mForce = Constants.ALPHA * tempData.getForce() + (1-Constants.ALPHA) * rightChartData[i-1].getForce();
        rightChartData.add(tempData);
      }
    }
  }

  void setupLeftChartData(){
    for(int i = 0; i < getLeftLiveData().length-1; i++){
      if(i == 0)
      {
        leftChartData.add(Data(getTimestamps()[i].time,getLeftLiveData()[i].force));
      }
      else
      {
        Data tempData = Data(getTimestamps()[i].time,getLeftLiveData()[i].force);
        tempData.mForce = Constants.ALPHA * tempData.getForce() + (1-Constants.ALPHA) * leftChartData[i-1].getForce();
        leftChartData.add(tempData);
      }
    }
  }
  ///Getter for Excel doc. saving path.
  getAttachments(){
    return hCardModel.excelPath;
  }
  ///Setter for Excel dock the save path.
  addAttachment(String path){
    hCardModel.excelPath = path;
  }
  /// Updates the chart in view when data is changed.
  List<SplineSeries<Data, int>> leftSplineSeries(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.blue,
        dataSource: leftChartData,
        width: 2,
        name: null,
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.timestamp,
        yValueMapper: (Data data, _) => data.mForce,
      ),
    ];
  }

  List<SplineSeries<Data, int>> rightSplineSeries(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.red,
        dataSource: rightChartData,
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
  ///Calculates the time to peak based on the array data since the
  ///ratio between sampled data array and time array is 1:1
  int getTimeToPeakForceLeft()
  {
    _timeToPeakForceLeft = _calcTimeToPeakForce(leftChartData);
    return _timeToPeakForceLeft;
  }
  int getTimeToPeakForceRight()
  {
    _timeToPeakForceRight =_calcTimeToPeakForce(rightChartData);
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
    //notifyListeners();
    return tempTime;
  }
  ///Calculates the highest value in the array, AKA peak force
  ///ratio between sampled data array and time array is 1:1
  double getPeakForceLeft()
  {
    _peakForceLeft = _calcPeakForce(leftChartData);
    return _peakForceLeft;
  }
  double getPeakForceRight()
  {
    _peakForceRight = _calcPeakForce(rightChartData);
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
    return tempVal;
  }
  double getAverageForceLeft()
  {
    _totalForceLeft = _calcTotalForce(leftChartData);
    _avgForceLeft = _calcAverageForce(leftChartData, _totalForceLeft);
    return _avgForceLeft;
  }
  double getAverageForceRight()
  {
    _totalForceRight = _calcTotalForce(rightChartData);
    _avgForceRight = _calcAverageForce(rightChartData, _totalForceRight);
    return _avgForceRight;
  }
  double getForceImpulseLeft()
  {
    _totalForceLeft = _calcTotalForce(leftChartData);
    _forceImpulseLeft = _calcForceImpulse(leftChartData, _totalForceLeft);
    return _forceImpulseLeft;
  }
  double getForceImpulseRight()
  {
    _totalForceRight = _calcTotalForce(rightChartData);
    _forceImpulseRight = _calcForceImpulse(rightChartData, _totalForceRight);
    return _forceImpulseRight;
  }
  ///Calculates the total force for the sample where noise is removed.
  double _calcTotalForce(List<Data> data)
  {
    double result = 0;
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
    return result;
  }
  ///Calculates the slope of the plotted function. Slope value represents Rate of Force Development
  double getRFDLeft()
  {
    _RFDLeft = _calcRFD(leftChartData);
    return _RFDLeft;
  }
  double getRFDRight()
  {
    _RFDRight = _calcRFD(rightChartData);
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
    //notifyListeners();
    return slope;
  }
  ///Calculates the average force were noise can no longer be detected
  double _calcAverageForce(List<Data> data, double totalForce)
  {
    var tempT1;
    var tempT2;
    //Get time where noise stops frmo the beginning of the list
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
    if(tempT1 == null && tempT2 == null)
    {
      return 0;
    }
    else
    {
      return totalForce/(tempT2-tempT1);
    }
  }
  ///Calculates the force impulse where noise can no longer be detected
  double _calcForceImpulse(List<Data> data, double totalForce)
  {
    var tempT1;
    var tempT2;
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
    if(tempT1 == null && tempT2 == null)
    {
      return 0;
    }
    else
    {
      return totalForce*(tempT2-tempT1);
    }
  }
}
