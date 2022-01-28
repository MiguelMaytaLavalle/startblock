import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/history_card_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  var hCardVM = HistoryCardViewModel();
  late SfCartesianChart chart;
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    refreshHistory();
  }

  Future refreshHistory() async {
    setState(() => hCardVM.setIsLoading(true));
    //this.history = await HistoryDatabase.instance.read(widget.historyId);
    hCardVM.setHistory(await HistoryDatabase.instance.read(widget.historyId));
    /*this.rightData = (json.decode(history.rightData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList();*/
    hCardVM.setRightHistory((json.decode(hCardVM.getHistory().rightData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());
    /*this.leftData = (json.decode(history.leftData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList();*/
    hCardVM.setLeftHistory((json.decode(hCardVM.getHistory().leftData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());
    //setState(() => isLoading = false);
    setState(() => hCardVM.setIsLoading(false));
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
                      //'${history.id.toString()}. ${history.name}',
                      '${hCardVM.getHistory().id.toString()}. ${hCardVM.getHistory().name}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      //DateFormat.yMMMMEEEEd().format(history.dateTime),
                      DateFormat.yMMMMEEEEd().format(hCardVM.getHistory().dateTime),
                      style: const TextStyle(color: Colors.blue),
                    ),
                    /*
          Text(
            history.liveData,
            style: const TextStyle(color: Colors.blue, fontSize: 18),
          )
          */
                    Container(
                      height: 400,
                      child: SfCartesianChart(
                        //title: ChartTitle(text: "Startblock"),
                        //crosshairBehavior: _crosshairBehavior,
                        legend: Legend(isVisible: true),
                        //zoomPanBehavior: _zoomPanBehavior,
                        series: _getLiveUpdateSeries(),
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
              //onPressed: () => _createExcel,
              onPressed: () {  },
              child: const Icon(Icons.delete),
            )
        ),
        Container(
            margin:const EdgeInsets.all(10),
            child: ElevatedButton(
              //onPressed: () => initGo(),
              onPressed: () {  },
              child: const Icon(Icons.email),
            )
        ),
      ],
    ),
      );
  /// Updates the chart
  List<SplineSeries<LiveData, int>> _getLiveUpdateSeries() {
    return <SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        //dataSource: rightData,
        dataSource: hCardVM.getRightHistory(),
        width: 2,
        name: 'Right foot',
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
      SplineSeries<LiveData, int>(
        //dataSource: leftData,
        dataSource: hCardVM.getLeftHistory(),
        width: 2,
        name: 'Left foot',
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
    ];
  }
}

