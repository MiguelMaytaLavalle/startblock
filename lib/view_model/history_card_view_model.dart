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

  getHistoryId(){
    return hCardModel.history.id;
  }

  getDateTime(){
    return hCardModel.history.dateTime;
  }

  getHistoryName(){
    return hCardModel.history.name;
  }

  setHistory(History hist){
    hCardModel.history = hist;
  }

  getRightLiveData(){
    return hCardModel.rightData;
  }

  setRightHistory(List<LiveData> list){
    hCardModel.rightData = list;
  }

  getLeftLiveData(){
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

  getHCardModel(){
    return hCardModel;
  }

}
