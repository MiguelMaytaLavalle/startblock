import 'dart:async';
import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
    Timer.periodic(const Duration(milliseconds: 500), updateDataSource);

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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sensor'),
        ),
        body: Container(
          height: 400,
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

                    if (snapshot.connectionState == ConnectionState.active) {
                       var currentValue = _dataParser(snapshot.data!);
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
                                  name: 'Right foot',
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

                    } else {
                      return const Text('Check the stream');
                    }


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

    //print("TRACEDUST $traceDust");
    chartData.add(LiveData(time++, traceDust.last));
    //traceDust.removeLast();

    if (chartData.length == 15) {
      chartData.removeAt(0);
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[chartData.length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[chartData.length - 1],
      );
    }
      // Removes the last index data of data source.
    // chartData.removeAt(0);
      // Here calling updateDataSource method with addedDataIndexes to add data in last index and removedDataIndexes to remove data from the last.
      // _chartSeriesController.updateDataSource(addedDataIndexes: <int>[chartData.length - 1],
      //     removedDataIndexes: <int>[0]);

      //print("CHARTDATA ${chartData.length}");

    /*_chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1);*/

    //print(chartData.length);
    //chartData.removeAt(0);
  }

}

class LiveData {
  LiveData(this.time, this.speed); //Constructor
  final int time;
  final num speed;
}
