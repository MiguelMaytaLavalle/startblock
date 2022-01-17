import 'dart:async';
import 'dart:convert' show utf8;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:startblock/constant/constants.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  var sensorPageViewModel = SensorPageViewModel();
  late Stream<List<int>> stream;
  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  late ZoomPanBehavior _zoomPanBehavior;
  late CrosshairBehavior _crosshairBehavior;
  //late Timer timer;


  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
    _crosshairBehavior = CrosshairBehavior(enable: true);
    Timer.periodic(const Duration(milliseconds: 500), updateDataSource);
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    Timer(const Duration(seconds: 15), () {
      //if (!isReady) {
      if(!sensorPageViewModel.getIsReady()){
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

   // connectServicesAndCharacteristics(Contants.SERVICE_UUID, Contants.CHARACTERISTIC_UUID);

   /// Reads the UART services and characteristics for the Micro:Bit
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      print("Servfound ${service.uuid.toString()}");
      if (service.uuid.toString() == Contants.SERVICE_UUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == Contants.CHARACTERISTIC_UUID) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            setState(() {
              sensorPageViewModel.setIsReady(true);
            });
          }
        }
      }
    }

    //if (!isReady) {
    if (!sensorPageViewModel.getIsReady()){
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
    final ButtonStyle style =
      ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Startblock'),
        ),
        body: SizedBox(
          height: 500,
            child: !sensorPageViewModel.getIsReady()
                ? const Center(
              child: Text(
                "Connecting...",
                style: TextStyle(fontSize: 24, color: Colors.blue),
              ),
            )
                : StreamBuilder<List<int>>(
                  stream: stream,
                  builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.active) {
                      readData(snapshot);
                      return SafeArea(
                          child: Scaffold(
                            body: SfCartesianChart(
                              //title: ChartTitle(text: "Startblock"),
                              crosshairBehavior: _crosshairBehavior,
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
                      );
                    } else { return const Text('Check the stream'); }
                  },
                )
        ),
        floatingActionButton:Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () => _createExcel,
                  child: const Icon(Icons.save_alt),
                )
            ),
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () => initGo(),
                  child: const Text('START'),
                )
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createExcel() async {
// Create a new Excel Document.
    final Workbook workbook = Workbook();

// Accessing worksheet via index.
    final Worksheet sheet = workbook.worksheets[0];

// Set the text value.
    sheet.getRangeByName('A1').setText('Hello World!');

// Save and dispose the document.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

// Save the Excel file in the local machine.
    File('Output.xlsx').writeAsBytes(bytes);

  }


  /**
   * Updates the data sources for right and left foot
   */
  void updateDataSource(Timer timer) {
    //if (sensorPageViewModel.getTime() == 15) {
      //timer.cancel();
    //}

    //chartData.add(LiveData(time++, traceDust.last));

      sensorPageViewModel.getRightChartData().add(LiveData(
          sensorPageViewModel.getTime(),
          sensorPageViewModel.getRightFootArray().last));
    sensorPageViewModel.getLeftChartData().add(LiveData(
        sensorPageViewModel.getTime(),
        sensorPageViewModel.getLeftFootArray().last));
    if(sensorPageViewModel.getRightChartData().length == 20 && sensorPageViewModel.getLeftChartData().length == 20)
      {
        sensorPageViewModel.getRightChartData().removeAt(0);
        _chartSeriesRightController.updateDataSource(
            addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],removedDataIndex: 0
        );
        sensorPageViewModel.getLeftChartData().removeAt(0);
        _chartSeriesLeftController.updateDataSource(
            addedDataIndexes: <int>[sensorPageViewModel.getLeftChartData().length - 1],removedDataIndex: 0
        );
      }
    else
    {
      _chartSeriesRightController.updateDataSource(
          addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],removedDataIndex: 0
      );
      _chartSeriesLeftController.updateDataSource(
          addedDataIndexes: <int>[sensorPageViewModel.getLeftChartData().length - 1],removedDataIndex: 0
      );
    }
/*    if(sensorPageViewModel.getRightChartData().length == 15){
      sensorPageViewModel.getRightChartData().removeAt(0);
      sensorPageViewModel.getLeftChartData().removeAt(0);

      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],
        removedDataIndexes: <int>[0],
      );
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getLeftChartData().length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],
      );
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getLeftChartData().length - 1],

      );
    }*/
      sensorPageViewModel.incrementTime();

    /*sensorPageViewModel.getRightChartData().add(LiveData(sensorPageViewModel.getTime(), sensorPageViewModel.getRightFootArray().last));
    sensorPageViewModel.getLeftChartData().add(LiveData(sensorPageViewModel.getTime(), sensorPageViewModel.getLeftFootArray().last));

    if(sensorPageViewModel.getRightChartData().length == 15){
      sensorPageViewModel.getRightChartData().removeAt(0);
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],
        removedDataIndexes: <int>[0],
      );
    } else {
      _chartSeriesController.updateDataSource(
        addedDataIndexes: <int>[sensorPageViewModel.getRightChartData().length - 1],
      );
    }
    sensorPageViewModel.incrementTime();*/
  }

  void readData(AsyncSnapshot<List<int>> snapshot) {
    var currentValue = _dataParser(snapshot.data!);
    var tag = currentValue.split(':');
    switch(tag[0]){
      case 'RF': {
        sensorPageViewModel.getRightFootArray().add(int.tryParse(tag[1]) ?? 0);
      }
      break;
      case 'LF': {
        sensorPageViewModel.getLeftFootArray().add(int.tryParse(tag[1]) ?? 0);
      }
      break;
      default:{
        print('No data to read');
      }
      break;
    }
  }

  /// Updates the chart
  List<SplineSeries<LiveData, int>> _getLiveUpdateSeries() {
    return <SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        dataSource: sensorPageViewModel.getLeftChartData()!,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.speed,
      ),
      SplineSeries<LiveData, int>(
        dataSource: sensorPageViewModel.getRightChartData()!,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.speed,
      ),
    ];
  }

  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit
    List<BluetoothService> services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == Contants.LEDSERVICE_SERVICE_UUID) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Contants.LEDTEXT_CHARACTERISTIC_UUID) {
            //characteristic.setNotifyValue(!characteristic.isNotifying);
            String test = ',1';
            List<int> bytes = utf8.encode(test);

            await c.write(bytes);
          }
        }
      }
    }
  }

}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        debugPrint('Received click');
      },
      child: const Text('Click Me'),
    );
  }
}

