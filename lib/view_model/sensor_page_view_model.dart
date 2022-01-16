import 'package:startblock/model/sensor_page_model.dart';

class SensorPageViewModel{
  var sensorPageModel = SensorPageModel();

  getTimer(){
    return sensorPageModel.timer;
  }

  getTime(){
    return sensorPageModel.time;
  }

  getIsReady(){
    return sensorPageModel.isReady;
  }

  setIsReady(bool set){
    sensorPageModel.isReady = set;
  }

  getTraceDust(){
    return sensorPageModel.traceDust;
  }

  getRightFootArray(){
    return sensorPageModel.rightFootArray;
  }

  getLeftFootArray(){
    return sensorPageModel.leftFootArray;
  }

  void incrementTime() {
    sensorPageModel.time++;
  }

  getLeftChartData() {
    return sensorPageModel.leftChartData;
  }

  getRightChartData() {
    return sensorPageModel.rightChartData;
  }

  /// Remove the very first index from the arrays that represents the chart
  /// to keep the chart live without stacking up
  void removeDataAtIndexZero() {
    sensorPageModel.rightChartData.removeAt(0);
    //sensorPageModel.leftChartData.removeAt(0);
  }
}
