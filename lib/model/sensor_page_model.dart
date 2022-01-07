import 'dart:async';
import 'livedata.dart';

class SensorPageModel{
  late List<LiveData> chartData = <LiveData>[];
  List<int> traceDust = [];
  late Timer timer;
  int time = 0;
  late bool isReady = false;
}
