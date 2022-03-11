import 'dart:async';
import 'livedata.dart';

class SensorModel{
  late List<LiveData> chartData = <LiveData>[];
  late List<LiveData> rightChartData = <LiveData>[];
  late List<LiveData> leftChartData = <LiveData>[];
  late List<LiveData> timess = <LiveData>[];

  late List<double> rightFootArray = <double>[];
  late List<double> leftFootArray = <double>[];
  List<int> times = [];

  late Timer timer;
  int time = 0;
  late bool isReady = false;
  late bool isLoading = true;
}
