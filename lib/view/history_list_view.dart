import 'package:flutter/gestures.dart';
import 'package:startblock/view/history_card.dart';

import '../db/history_database.dart';
import 'package:flutter/material.dart';
import 'package:startblock/model/history.dart';

class HistoryPage extends StatefulWidget{
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<History> histories;
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

  Future refreshHistory() async {
    setState(() => isLoading = true);
    histories = await HistoryDatabase.instance.readAllHistory();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'History',
        style: TextStyle(fontSize: 24),
      ),
      actions: [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? CircularProgressIndicator()
          : histories.isEmpty
          ? const Text('No History', style: TextStyle(color: Colors.white, fontSize: 24),)
          : buildHistory(),
    ),
  );

  Widget buildHistory() => ListView.separated(
    padding: const EdgeInsets.all(8),
    itemCount: histories.length,
    itemBuilder: (context, index) {
      final history = histories[index];
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
          child: Center(child: Text('Entry $history')),
        )
      );

/*      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HistoryDetailPage(historyId: history.id!),
          ));

          refreshHistory();
        },
        child: NoteCardWidget(note: note, index: index),
      );*/

    }, separatorBuilder: (BuildContext context, int index) => const Divider() ,
  );

}

