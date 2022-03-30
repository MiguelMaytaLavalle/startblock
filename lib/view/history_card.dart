import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/helper/excel.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/timestamp.dart';
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
  final ButtonStyle style =
  ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));
  HistoryCardViewModel hCardVM = HistoryCardViewModel();

  //SendEmailViewModel sendEmailVM = SendEmailViewModel();
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

    hCardVM.setRightHistory(
        (json.decode(hCardVM.getHistory().rightData) as List)
            .map((e) => LiveData.fromJson(e))
            .toList());

    hCardVM.setLeftHistory((json.decode(hCardVM.getHistory().leftData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());

    hCardVM.setTimestampsHistory(
        (json.decode(hCardVM.getHistory().timestamps) as List)
            .map((e) => Timestamp.fromJson(e))
            .toList());

    hCardVM.setMarzulloHistory(hCardVM.getMarzullo());

    hCardVM.setImuData((json.decode(hCardVM.getHistory().imuData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());

    hCardVM.setImuTimestamps(
        (json.decode(hCardVM.getHistory().imuTimestamps) as List)
            .map((e) => Timestamp.fromJson(e))
            .toList());

    hCardVM.setMovesenseArriveTime(
        (json.decode(hCardVM.getHistory().movesenseArriveTime) as List)
            .map((e) => Timestamp.fromJson(e))
            .toList());

    setState(() => hCardVM.setIsLoading(false));

    hCardVM.setupLeftChartData();
    hCardVM.setupRightChartData();
    _attachExcel();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
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
                    Text(
                      'Marzullo: ${hCardVM.getMarzullo().toString()}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SfCartesianChart(
                              //crosshairBehavior: _crosshairBehavior,
                              legend: Legend(isVisible: true),
                              //zoomPanBehavior: _zoomPanBehavior,
                              //series: sensorPageVM.getDataRight(),
                              series: hCardVM.leftSplineSeries(),
                              primaryXAxis: NumericAxis(
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                  interval: 1000,
                                  //1000ms between two timestamps equals a second
                                  title: AxisTitle(text: 'Time [S]')),

                              primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  //maximum: 800,
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'Force [N]')),
                            ),
                            Wrap(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Rate of force (RFD): ${hCardVM.getRFDLeft().toStringAsPrecision(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Time to peak (TTP): ${hCardVM.getTimeToPeakForceLeft()}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Average Force: ${hCardVM.getAverageForceLeft().toStringAsFixed(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Force impulse: ${hCardVM.getForceImpulseLeft().toStringAsPrecision(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Peak force: ${hCardVM.getPeakForceLeft().toStringAsPrecision(2)}')),
                              ],
                            ),
                            SfCartesianChart(
                              //crosshairBehavior: _crosshairBehavior,
                              legend: Legend(isVisible: true),
                              //zoomPanBehavior: _zoomPanBehavior,
                              //series: sensorPageVM.getDataRight(),
                              series: hCardVM.rightSplineSeries(),
                              primaryXAxis: NumericAxis(
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                  interval: 1000,
                                  //1000ms between two timestamps equals a second
                                  title: AxisTitle(text: 'Time [S]')),

                              primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  //maximum: 800,
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'Force [N]')),
                            ),
                            Wrap(
                              direction: Axis.vertical,
                              children: <Widget>[
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Rate of force (RFD): ${hCardVM.getRFDRight().toStringAsPrecision(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Time to peak (TTP): ${hCardVM.getTimeToPeakForceRight()}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Average Force: ${hCardVM.getAverageForceRight().toStringAsFixed(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Force impulse: ${hCardVM.getForceImpulseRight().toStringAsPrecision(2)}')),
                                Material(
                                    //margin:const EdgeInsets.all(10),
                                    child: Text(
                                        'Peak force: ${hCardVM.getPeakForceRight().toStringAsPrecision(2)}')),
                              ],
                            ),
                            //const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),

        floatingActionButton: Wrap(
          spacing: 20,
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: openDialog,
                  child: const Icon(Icons.delete),
                )),
            Container(
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Share.shareFiles([hCardVM.getAttachments()]);
                  },
                  child: const Icon(Icons.share),
                )),
          ],
        ),
      );

  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Do you want to delete this log?'),
          actions: [
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: _deleteHistory,
            ),
          ],
        ),
      );

  Future _deleteHistory() async {
    Navigator.of(context).pop();
    await HistoryDatabase.instance.delete(widget.historyId);
    Navigator.of(context).pop();
  }

  _attachExcel() async {
    try {
      String tmp = await exportExcel.attachExcel(hCardVM.getHCardModel());
      hCardVM.addAttachment(tmp);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Exported excel file succesfully')));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("NO ${error.toString()}")));
    }
  }
}
