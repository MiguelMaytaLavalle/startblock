import 'package:intl/intl.dart';
import 'package:startblock/view/history_card.dart';
import 'package:startblock/view_model/history_list_view_model.dart';

import '../db/database_helper.dart';
import 'package:flutter/material.dart';

/// This view will present all the recorded episodes from the database.
/// Each recorded episode will be presented as a selectable button with its name and recorded date.
/// A user can select and open up an episode for more details in a new view.
///
class HistoryScreen extends StatefulWidget{
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  var historyListViewModel = HistoryListViewModel();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshHistory();
  }

  @override
  void dispose() {
    HistoryDatabase.instance.close();
    super.dispose();
  }

  /// Calls the database for fetching all the recorded episodes.
  Future refreshHistory() async {
    setState(() => isLoading = true);
    historyListViewModel.setHistoryList(await HistoryDatabase.instance.readAllHistory());
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(historyListViewModel.historyListTitle,
        style: TextStyle(fontSize: 24),
      ),
      actions: [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? CircularProgressIndicator()
          //: listHistory.isEmpty
          : historyListViewModel.getHistoryList().isEmpty
          ? const Text('No History', style: TextStyle(color: Colors.white, fontSize: 24),)
          : buildHistory(),
    ),
  );

  Widget buildHistory() => ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: historyListViewModel.getHistoryList().length,
    itemBuilder: (context, index) {
      final history = historyListViewModel.getHistoryList()[index];
      String date = DateFormat.yMMMd().format(history.dateTime);
      return GestureDetector(
        onTap: () async{
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HistoryCard(historyId: history.id!),
          ));
          refreshHistory();
        },
        child: Container(
          height: 70,
          color: Colors.amber,
          child: Center(child: Text('${index+1}. ${history.name} $date')),
        )
      );
    }, separatorBuilder: (BuildContext context, int index) => const Divider() ,
  );

}

