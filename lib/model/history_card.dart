import 'package:startblock/model/history.dart';

import 'livedata.dart';

class HistoryCardModel{
  late History history;
  bool isLoading = false;
  late List<LiveData> rightData = [];
  late List<LiveData> leftData = [];
}
