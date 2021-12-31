import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    chartData.add(LiveData(time++, (math.Random().nextInt(60) + 30)));
    //chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1);
    print(chartData.length);
  }

  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(0, 42),
      LiveData(1, 47),
      LiveData(2, 43),
      LiveData(3, 49),
      LiveData(4, 54),
      LiveData(5, 41),
      LiveData(6, 58),
      LiveData(7, 51),
      LiveData(8, 98),
      LiveData(9, 41),
      LiveData(10, 53),
      LiveData(11, 72),
      LiveData(12, 86),
      LiveData(13, 52),
      LiveData(14, 94),
      LiveData(15, 92),
      LiveData(16, 86),
      LiveData(17, 72),
      LiveData(18, 94)
    ];
  }
}

class LiveData {
  LiveData(this.time, this.speed); //Constructor
  final int time;
  final num speed;
}
