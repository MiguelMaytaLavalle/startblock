import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_list.dart';

class HistoryListViewModel{
  String historyListTitle = 'History List';

  var historyListModel = HistoryListModel();

  getHistoryList(){
    return historyListModel.historyListData;
  }
  setHistoryList(List<History> list){
    historyListModel.historyListData = list;
  }
}
