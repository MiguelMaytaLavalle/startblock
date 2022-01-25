import 'dart:async';
import 'livedata.dart';

class SensorModel{
  late List<LiveData> chartData = <LiveData>[];
  late List<LiveData> rightChartData = <LiveData>[];
  late List<LiveData> leftChartData = <LiveData>[];

  List<int> rightFootArray = [];
  List<int> leftFootArray = [];
  late Timer timer;
  int time = 0;
  late bool isReady = false;
}
