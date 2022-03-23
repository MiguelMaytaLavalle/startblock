import 'package:startblock/model/history.dart';
import 'package:startblock/model/timestamp.dart';

import 'livedata.dart';

class HistoryCardModel{
  late History history;
  bool isLoading = false;

  late List<LiveData> rightData = <LiveData>[];
  late List<LiveData> leftData = <LiveData>[];
  late List<Timestamp> timestamps = <Timestamp>[];
  late num marzullo;
}
