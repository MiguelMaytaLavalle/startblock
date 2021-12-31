import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:oscilloscope/oscilloscope.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400002-b5a3-f393-e0a9-e50e24dcca9e";
  late bool isReady;
  late Stream<List<int>> stream;
  List<double> traceDust = [];
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;
  late ZoomPanBehavior _zoomPanBehavior;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    chartData = <LiveData>[];//getChartData();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
    Timer.periodic(const Duration(milliseconds: 5), updateDataSource);

    isReady = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;

            setState(() {
              isReady = true;
            });
          }
        }
      }
    }

    if (!isReady) {
      _Pop();
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
        AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you want to disconnect device and go back?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
            TextButton(
                onPressed: () {
                  disconnectFromDevice();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Yes')),
          ],
        )
    ).then((value) => value ?? false);
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {
    /*Oscilloscope oscilloscope = Oscilloscope(
      showYAxis: true,
      //TODO deprecated padding change to margin
      padding: 0.0,
      backgroundColor: Colors.black,
      traceColor: Colors.white,
      yAxisMax: 3000.0,
      yAxisMin: 0.0,
      dataSet: traceDust,
    );*/

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sensor'),
        ),
        body: Container(
            child: !isReady
                ? const Center(
              child: Text(
                "Waiting...",
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
            )
                : StreamBuilder<List<int>>(
                  stream: stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                    /*if (snapshot.connectionState ==
                        ConnectionState.active) {*/
                      var currentValue = _dataParser(snapshot.data!);
                      print("CURRENT VALUE $currentValue");
                      traceDust.add(double.tryParse(currentValue) ?? 0);

                      return SafeArea(
                          child: Scaffold(
                            body: SfCartesianChart(
                              title: ChartTitle(text: "Micro:Bit"),
                              legend: Legend(isVisible: true),
                              zoomPanBehavior: _zoomPanBehavior,
                              series: <ChartSeries>[
                                SplineSeries<LiveData, int>(
                                  dataSource: chartData,
                                  //chartData lateInitializationError
                                  name: 'sensor',
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
                                  title: AxisTitle(text: 'Value (Analog)')),
                            ),
                          )
                      );

                      /*
                      return Center(

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Text('Current value from Sensor',
                                          style: TextStyle(fontSize: 14)),
                                      Text('${currentValue}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24))
                                    ]),
                              ),
                              Expanded(
                                flex: 1,
                                child: oscilloscope,
                              )
                            ],
                          )
                      );
                      */
                    /*} else {
                      return const Text('Check the stream');
                    }*/
                  },
                )),
      ),
    );
  }

  int time = 0;
  void updateDataSource(Timer timer) {
    /*if (time == 100) {
      timer.cancel();
    }*/
    //print("TRACEDUST ${traceDust}");
    chartData.add(LiveData(time++, traceDust.last));
    //chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1);
    //print(chartData.length);
  }

  /*List<LiveData> getChartData() {
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
  }*/

}

class LiveData {
  LiveData(this.time, this.speed); //Constructor
  final int time;
  final num speed;
}
