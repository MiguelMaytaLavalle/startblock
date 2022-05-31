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

  ExportToExcel exportExcel = ExportToExcel();
  late SfCartesianChart chart;
  late TooltipBehavior _tooltipBehavior;
  late CrosshairBehavior _crosshairBehavior;
  late TextEditingController controller;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    controller = TextEditingController();
    _crosshairBehavior = CrosshairBehavior(
      // Enables the crosshair
        enable: true
    );
    super.initState();
    refreshHistory();
  }

  /// When this view is invoked it will fetch the selected episode and present the data in this view.
  /// It will also create an excel file after fetching the data.
  Future refreshHistory() async {
    setState(() => hCardVM.setIsLoading(true));

    hCardVM.setHistory(await HistoryDatabase.instance.read(widget.historyId));

    hCardVM.setRightHistory((json.decode(hCardVM.getHistory().rightData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());

    hCardVM.setLeftHistory((json.decode(hCardVM.getHistory().leftData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());

    hCardVM.setTimestampsHistory((json.decode(hCardVM.getHistory().timestamps) as List)
        .map((e) => Timestamp.fromJson(e))
        .toList());

    hCardVM.setMarzulloHistory(hCardVM.getMarzullo());

    hCardVM.setImuData((json.decode(hCardVM.getHistory().imuData) as List)
        .map((e) => LiveData.fromJson(e))
        .toList());

    hCardVM.setImuTimestamps((json.decode(hCardVM.getHistory().imuTimestamps) as List)
        .map((e) => Timestamp.fromJson(e))
        .toList());

    hCardVM.setMovesenseArriveTime((json.decode(hCardVM.getHistory().movesenseArriveTime) as List)
        .map((e) => Timestamp.fromJson(e))
        .toList());

    hCardVM.setLastServerTime(hCardVM.getLastServerTime());

    hCardVM.setMarzulloCreationTime(hCardVM.getMarzulloCreationTime());

    hCardVM.setStartSampleTime(hCardVM.getStartSampleTime());

    hCardVM.setStopSampleTime(hCardVM.getStopSampleTime());

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
                        child:Column(
                          children: [
                            SfCartesianChart(
                              crosshairBehavior: _crosshairBehavior,
                              legend: Legend(isVisible: false),
                              //zoomPanBehavior: _zoomPanBehavior,
                              //series: sensorPageVM.getDataRight(),
                              series: hCardVM.leftSplineSeries(),
                              primaryXAxis: NumericAxis(
                                isVisible:true,
                                  //Uncomment if X-axis shall be visible and set isVisible = true;

                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  majorGridLines: const MajorGridLines(width: 1),
                                  axisLine: AxisLine(width:1),
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                  interval: 1000, //1000ms between two timestamps equals a second
                                  //title: AxisTitle(text: 'Time [S]')

                              ),

                              primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  axisLine: const AxisLine(width: 0),
                                  majorTickLines: const MajorTickLines(size: 0),
                                  title: AxisTitle(text: 'Force [N]')),
                            ),
                            SfCartesianChart(
                              legend: Legend(isVisible: false),
                              series: hCardVM.rightSplineSeries(),
                              primaryXAxis: NumericAxis(
                                isVisible:true,
                                //Uncomment if X-axis shall be visible and set isVisible = true;

                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  majorGridLines: const MajorGridLines(width: 1),
                                  axisLine: AxisLine(width:1),
                                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                                  interval: 1000, //1000ms between two timestamps equals a second
                                  //title: AxisTitle(text: 'Time [S]')
                              ),

                              primaryYAxis: NumericAxis(
                                  minimum: 0,
                                  interactiveTooltip: const InteractiveTooltip(
                                    enable: true,
                                  ),
                                  axisLine: const AxisLine(width: 1),
                                  majorTickLines: const MajorTickLines(size: 1),
                                  title: AxisTitle(text: 'Force [N]')),
                            ),
                            Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.start,
                              children: [
                                const Material(
                                    child: Text('Left Foot Data',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontWeight: FontWeight.bold,
                                      color: Colors.blue
                                      ),
                                    )
                                ),
                                Material(
                                    child: Text('Rate of force (RFD): ${hCardVM.getRFDLeft()
                                        //.toString()}'
                                      .toStringAsFixed(3)}'
                                    )
                                ),
                                Material(
                                    child: Text('Time to peak (TTP): ${hCardVM.getTimeToPeakForceLeft()
                                    .toStringAsFixed(3)}'
                                    )
                                ),
                                Material(
                                    child: Text('Average Force: ${hCardVM.getAverageForceLeft()
                                        .toStringAsFixed(3)}'
                                    )
                                ),
                                Material(
                                    child: Text('Force impulse: ${hCardVM.getForceImpulseLeft()
                                    .toStringAsFixed(3)}'
                                    )
                                ),
                                Material(
                                    child: Text('Peak force: ${hCardVM.getPeakForceLeft()
                                    .toStringAsPrecision(10)}'
                                    )
                                ),
                              ],
                            ),

                            Wrap(
                              direction: Axis.vertical,
                              children: <Widget>[
                                const Material(
                                    child: Text('Right foot data',
                                      textAlign: TextAlign.left,
                                    style: TextStyle(fontWeight: FontWeight.bold,
                                    color: Colors.red
                                      ),
                                    )
                                ),
                                Material(
                                    child: Text(
                                        'Rate of force (RFD): ${hCardVM.getRFDRight()
                                            //.toString()}')),
                                            .toStringAsFixed(3)}')),
                                Material(
                                    child: Text(
                                        'Time to peak (TTP): ${hCardVM.getTimeToPeakForceRight().toStringAsFixed(3)}')),
                                Material(
                                    child: Text(
                                        'Average Force: ${hCardVM.getAverageForceRight().toStringAsFixed(3)}')),
                                Material(
                                    child: Text(
                                        'Force impulse: ${hCardVM.getForceImpulseRight().toStringAsFixed(3)}')),
                                Material(
                                    child: Text(
                                        'Peak force: ${hCardVM.getPeakForceRight().toStringAsFixed(3)}')),
                              ],
                            ),
                            const SizedBox(height: 60),
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
                margin: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Share.shareFiles([hCardVM.getAttachments()]);
                  },
                  child: const Icon(Icons.share),
                )),
          ],
        ),
      );

  /***
   * This method will be invoked when a user wants to delete a episode from the database.
   */
  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Do you want to delete this log?'),
          actions: [
            TextButton(
              child: const Text('No'),
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

  /// This method will be invoked at the start after fetching the selected episode.
  /// It will create the excel file from the episode and return the filepath for when a user wants to share the excel file.
  _attachExcel() async {
    try {
      String tmp = await exportExcel.attachExcel(hCardVM.getHCardModel());
      hCardVM.addAttachment(tmp);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exported to excel successfully')));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Can't export the data to excel! ${error.toString()}")));
    }
  }
}
