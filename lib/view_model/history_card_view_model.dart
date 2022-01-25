import 'package:startblock/model/history.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/model/livedata.dart';

class HistoryCardViewModel{
  // Provide all the state = data needed by the home view
  String hCardTitle = 'Test';

// Will contain all business logic
  var hCardModel = HistoryCardModel();

  getHistory(){
    return hCardModel.history;
  }

  setHistory(History hist){
    hCardModel.history = hist;
  }

  getRightHistory(){
    return hCardModel.rightData;
  }
  setRightHistory(List<LiveData> list){
    hCardModel.rightData = list;
  }
  getLeftHistory(){
    return hCardModel.leftData;
  }
  setLeftHistory(List<LiveData> list){
    hCardModel.leftData = list;
  }
  getIsLoading(){
    return hCardModel.isLoading;
  }
  setIsLoading(bool i){
    hCardModel.isLoading = i;
  }

}
