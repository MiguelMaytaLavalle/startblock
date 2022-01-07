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

  getChartData() {
    return sensorPageModel.chartData;
  }

  getTraceDust(){
    return sensorPageModel.traceDust;
  }

  void incrementTime() {
    sensorPageModel.time++;
  }
}
