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
  ///Returns an array with timestamps
  getTimes()
  {
    return sensorPageModel.times;
  }
  ///Clears arrays that contains data.
  flushData()
  {
    sensorPageModel.rightFootArray.clear();
    sensorPageModel.leftFootArray.clear();
    sensorPageModel.leftChartData.clear();
    sensorPageModel.rightChartData.clear();


    print(sensorPageModel.rightFootArray.length);
    print(sensorPageModel.leftFootArray.length);
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
}
