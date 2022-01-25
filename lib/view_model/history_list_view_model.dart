import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_list.dart';

class HistoryListViewModel{
  // Provide all the state = data needed by the home view
  String historyListTitle = 'History List';

// Will contain all business logic
  var historyListModel = HistoryListModel();

  getHistoryList(){
    return historyListModel.historyListData;
  }
  setHistoryList(List<History> list){
    historyListModel.historyListData = list;
  }
}
