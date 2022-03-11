import 'package:startblock/model/livedata.dart';
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

  getIsLoading(){
    return sensorPageModel.isLoading;
  }

  setIsLoading(bool set){
    sensorPageModel.isLoading = set;
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

  setLeftChartData(List<LiveData> leftList){
    sensorPageModel.leftChartData = leftList;
  }

  getRightChartData() {
    return sensorPageModel.rightChartData;
  }

  setRightChartData(List<LiveData> rightList){
    sensorPageModel.rightChartData = rightList;
  }


  getTimes()
  {
    return sensorPageModel.times;
  }


  flushData()
  {
    sensorPageModel.rightFootArray.clear();
    sensorPageModel.leftFootArray.clear();
    sensorPageModel.leftChartData.clear();
    sensorPageModel.rightChartData.clear();


    print(sensorPageModel.rightFootArray.length);
    print(sensorPageModel.leftFootArray.length);
  }
}
