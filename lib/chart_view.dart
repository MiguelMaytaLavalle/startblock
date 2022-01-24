import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'model/livedata.dart';

class Chart extends StatefulWidget {
  @override
  State<Chart> createState() {
    return _ChartSate();
  }
}

class _ChartSate extends State<Chart> {
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  late ZoomPanBehavior _zoomPanBehavior;
  late Timer timer;

  @override
  void initState() {
    chartData = getChartData();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: SfCartesianChart(
            title: ChartTitle(text: "Test"),
            legend: Legend(isVisible: true),
            zoomPanBehavior: _zoomPanBehavior,
            series: <ChartSeries>[
              LineSeries<LiveData, int>(
                dataSource: chartData,
            //chartData lateInitializationError
                  name: 'Test',
            //Legend name
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller; //Updates the chart live
            },
            xValueMapper: (LiveData livedata, _) => livedata.time,
            yValueMapper: (LiveData livedata, _) => livedata.speed,
          )
        ],
        primaryXAxis: NumericAxis(
            majorGridLines: const MajorGridLines(width: 0),
            edgeLabelPlacement: EdgeLabelPlacement.shift,
            interval: 3,
            title: AxisTitle(text: 'Time(seconds)')),
        primaryYAxis: NumericAxis(
            axisLine: const AxisLine(width: 0),
            majorTickLines: const MajorTickLines(size: 0),
            title: AxisTitle(text: 'Internet speed (Mbps)')),
      ),
    )
    );
  }

  int time = 19;

  void updateDataSource(Timer timer) {
    if (time == 30) {
      timer.cancel();
    }
    chartData.add(LiveData(time: time++, speed:(math.Random().nextInt(60) + 30)));
    //chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1);
    print(chartData.length);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(time:0, speed:42),
      LiveData(time:1, speed:47),
      LiveData(time:2, speed:43),
      LiveData(time:3, speed:49),
      LiveData(time:4, speed:54),
      LiveData(time:5, speed:41),
      LiveData(time:6, speed:58),
      LiveData(time:7, speed:51),
      LiveData(time:8, speed:98),
      LiveData(time:9, speed:41),
      LiveData(time:10, speed:53),
      LiveData(time:11, speed:72),
      LiveData(time:12, speed:86),
      LiveData(time:13, speed:52),
      LiveData(time:14, speed:94),
      LiveData(time:15, speed:92),
      LiveData(time:16, speed:86),
      LiveData(time:17, speed:72),
      LiveData(time:18, speed:94)
    ];
  }
}

