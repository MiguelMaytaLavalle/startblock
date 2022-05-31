import 'package:startblock/model/history.dart';
import 'package:startblock/model/timestamp.dart';

import 'livedata.dart';

class HistoryCardModel{
  late String _excelPath;
  late List<LiveData> _rightData = [];
  late List<LiveData> _leftData = [];
  late List<LiveData> _imuData = [];
  late List<Timestamp> timestamps = <Timestamp>[];
  late List<Timestamp> _imuTimestamps = [];
  late List<Timestamp> _movesenseArriveTime = [];
  late List<Timestamp> _timestampArrival = <Timestamp>[];
  bool _isLoading = false;
  late num _marzullo;
  late num _marzulloCreationTime;
  late num _lastServerTime;

  List<Timestamp> get timestampArrival => _timestampArrival;

  set timestampArrival(List<Timestamp> value) {
    _timestampArrival = value;
  }

  late num _startSampleTime;
  late num _stopSampleTime;

  set excelPath(String value) {
    _excelPath = value;
  }
  String get excelPath => _excelPath;
  late History _history;

  set history(History value) {
    _history = value;
  }
  History get history => _history;
  set isLoading(bool value) {
    _isLoading = value;
  }
  bool get isLoading => _isLoading;
  set rightData(List<LiveData> value) {
    _rightData = value;
  }

  set leftData(List<LiveData> value) {
    _leftData = value;
  }
  List<LiveData> get rightData => _rightData;

  List<LiveData> get leftData => _leftData;

  num get marzullo => _marzullo;

  set marzullo(num value) {
    _marzullo = value;
  }

  List<LiveData> get imuData => _imuData;

  set imuData(List<LiveData> value) {
    _imuData = value;
  }

  List<Timestamp> get imuTimestamps => _imuTimestamps;

  set imuTimestamps(List<Timestamp> value) {
    _imuTimestamps = value;
  }

  List<Timestamp> get movesenseArriveTime => _movesenseArriveTime;

  set movesenseArriveTime(List<Timestamp> value) {
    _movesenseArriveTime = value;
  }

  num get lastServerTime => _lastServerTime;

  set lastServerTime(num value) {
    _lastServerTime = value;
  }

  num get marzulloCreationTime => _marzulloCreationTime;

  set marzulloCreationTime(num value) {
    _marzulloCreationTime = value;
  }

  num get stopSampleTime => _stopSampleTime;

  set stopSampleTime(num value) {
    _stopSampleTime = value;
  }

  num get startSampleTime => _startSampleTime;

  set startSampleTime(num value) {
    _startSampleTime = value;
  }
}
