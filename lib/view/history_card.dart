import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';

class HistoryCard extends StatefulWidget {
  final int historyId;

  const HistoryCard({
    Key? key,
    required this.historyId,
  }) : super(key: key);

  @override
  _HistoryCardState createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  late History history;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshHistory();
  }

  Future refreshHistory() async {
    setState(() => isLoading = true);
    this.history = await HistoryDatabase.instance.read(widget.historyId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      //actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
      padding: EdgeInsets.all(12),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            history.name,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            DateFormat.yMMMd().format(history.dateTime),
            style: TextStyle(color: Colors.blue),
          ),
          SizedBox(height: 8),
          Text(
            history.name,
            style: TextStyle(color: Colors.blue, fontSize: 18),
          )
        ],
      ),
    ),
  );

}
