import 'package:startblock/model/sensor.dart';

class SensorPageViewModel{
  var sensorPageModel = SensorModel();

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
  getTimes()
  {
    return sensorPageModel.times;
  }
  flushData()
  {
    sensorPageModel.rightFootArray.clear();
    sensorPageModel.leftFootArray.clear();
    print(sensorPageModel.rightFootArray.length);
    print(sensorPageModel.leftFootArray.length);
  }
}
