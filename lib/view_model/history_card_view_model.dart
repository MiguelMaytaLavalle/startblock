import 'package:flutter/material.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/sensor.dart';
import '../model/timestamp.dart';

class HistoryCardViewModel{
  // Provide all the state = data needed by the home view
  String hCardTitle = 'Test';
  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  late List<Data> leftChartData = <Data>[];
  late List<Data> rightChartData = <Data>[];

// Will contain all business logic
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

  void setupRightChartData(){
    for(int i = 0; i < getRightLiveData().length; i++){
      rightChartData.add(Data(getTimestamps()[i].time,getRightLiveData()[i].force));
    }
  }

  void setupLeftChartData(){
    for(int i = 0; i < getLeftLiveData().length; i++){
      leftChartData.add(Data(getTimestamps()[i].time, getLeftLiveData()[i].force));
    }
  }

  /// Updates the chart
 /* List<SplineSeries<Data, int>> leftSplineSeries(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.blue,
        dataSource: leftChartData,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (Data data, _) => data.timestamp,
        yValueMapper: (Data data, _) => data.mForce,
      ),
    ];
  }*/

  List<SplineSeries<Data, int>> leftSplineSeries(){
    //notifyListeners();
    return<SplineSeries<Data, int>>[
      SplineSeries<Data, int>(
        color: Colors.blue,
        dataSource: leftChartData,
        width: 2,
        name: 'Left foot',
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

}
