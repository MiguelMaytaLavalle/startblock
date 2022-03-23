import 'package:flutter/material.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../model/sensor.dart';

class HistoryCardViewModel{
  // Provide all the state = data needed by the home view
  String hCardTitle = 'Test';
  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;

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

  getLeftLiveData(){
    return hCardModel.leftData;
  }

  setLeftHistory(List<LiveData> list){
    hCardModel.leftData = list;
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

  getAttachments(){
    return hCardModel.excelPath;
  }

  addAttachment(String path){
    hCardModel.excelPath = path;
  }
  /// Updates the chart
  List<SplineSeries<LiveData, int>> leftSplineSeries(){
    //notifyListeners();
    return<SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        color: Colors.blue,
        dataSource: hCardModel.leftData,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData data, _) => data.time,
        yValueMapper: (LiveData data, _) => data.force,
      ),
    ];
  }

  List<SplineSeries<LiveData, int>> rightSplineSeries(){
    //notifyListeners();
    return<SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        color: Colors.red,
        dataSource: hCardModel.rightData,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData data, _) => data.time,
        yValueMapper: (LiveData data, _) => data.force,
      ),
    ];
  }

}
