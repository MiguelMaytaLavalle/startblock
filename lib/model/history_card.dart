import 'package:startblock/model/history.dart';
import 'package:startblock/model/timestamp.dart';

import 'livedata.dart';

class HistoryCardModel{
  late String _excelPath;
  late List<LiveData> _rightData = [];
  late List<LiveData> _leftData = [];
  late List<Timestamp> timestamps = <Timestamp>[];
  bool _isLoading = false;
  late num _marzullo;

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
}
