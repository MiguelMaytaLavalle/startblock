import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/helper/excel.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/history_card_view_model.dart';
import 'package:startblock/view_model/send_email_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:share_plus/share_plus.dart';

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
  HistoryCardViewModel hCardVM = HistoryCardViewModel();
  SendEmailViewModel sendEmailVM = SendEmailViewModel();
  ExportToExcel exportExcel = ExportToExcel();
  late SfCartesianChart chart;
  late TooltipBehavior _tooltipBehavior;
  late TextEditingController controller;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    controller = TextEditingController();
    super.initState();
    refreshHistory();
  }

  Future refreshHistory() async {
    setState(() => hCardVM.setIsLoading(true));
    hCardVM.setHistory(await HistoryDatabase.instance.read(widget.historyId));
    hCardVM.setRightHistory((json.decode(hCardVM.getHistory().rightData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());
    hCardVM.setLeftHistory((json.decode(hCardVM.getHistory().leftData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());
    setState(() => hCardVM.setIsLoading(false));
    _attachExcel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            //actions: [editButton(), deleteButton()],
            ),
        body: hCardVM.getIsLoading()
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    Text(
                      '${hCardVM.getHistoryId().toString()}. ${hCardVM.getHistoryName()}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMMEEEEd().format(hCardVM.getDateTime()),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    Container(
                      height: 400,
                      child: SfCartesianChart(
                        legend: Legend(isVisible: true),
                        series: _getUpdateSeries(),
                        primaryXAxis: NumericAxis(
                            interactiveTooltip: const InteractiveTooltip(
                              enable: true,
                            ),
                            majorGridLines: const MajorGridLines(width: 0),
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            interval: 3,
                            title: AxisTitle(text: 'Time [S]')
                        ),
                        primaryYAxis: NumericAxis(
                            minimum: 0,
                            //maximum: 800,
                            interactiveTooltip: const InteractiveTooltip(
                              enable: true,
                            ),
                            axisLine: const AxisLine(width: 0),
                            majorTickLines: const MajorTickLines(size: 0),
                            title: AxisTitle(text: 'Force [N]')
                        ),
                      ),
                    ),
                  ],
                ),
              ),

    floatingActionButton:Wrap(
      direction: Axis.horizontal,
      children: <Widget>[
        Container(
            margin:const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: openDialog,
              child: const Icon(Icons.delete),
            )
        ),
        Container(
            margin: EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                Share.shareFiles([sendEmailVM.getAttachments()[0]]);
                },
              child: const Icon(Icons.email),
            )
        ),
      ],
    ),
      );
  /// Updates the chart
  List<SplineSeries<LiveData, int>> _getUpdateSeries() {
    return <SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        dataSource: hCardVM.getRightLiveData(),
        width: 2,
        name: 'Right foot',
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
      SplineSeries<LiveData, int>(
        dataSource: hCardVM.getLeftLiveData(),
        width: 2,
        name: 'Left foot',
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
    ];
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Do you want to delete this log?'),
      actions: [
        TextButton(
          child: Text('No'),
          onPressed: (){Navigator.of(context).pop();},
        ),
        TextButton(
          child: Text('Yes'),
          onPressed: _deleteHistory,
        ),
      ],
    ),
  );

  Future _deleteHistory() async{
    Navigator.of(context).pop();
    await HistoryDatabase.instance.delete(widget.historyId);
    Navigator.of(context).pop();
  }

  _attachExcel() async {
    try{
      String tmp = await exportExcel.attachExcel(hCardVM.getHCardModel());
      sendEmailVM.addAttachment(tmp);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported excel file succesfully')));
    }catch(error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("NO ${error.toString()}")));
    }

  }



}

