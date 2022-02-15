import 'dart:async';
import 'dart:convert' show utf8;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class microbitScreen extends StatelessWidget {

@override
Widget build(BuildContext context) {
  return  Scaffold(
    appBar: AppBar(
      title: Text('Microbit'),
    ),
    body: MicrobitScreen(),
  );
}

}


class MicrobitScreen extends StatefulWidget {
  @override
  _MicrobitState createState() => _MicrobitState();
}

class _MicrobitState extends State<MicrobitScreen> {
  var sensorPageVM = SensorPageViewModel();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;
  late List<BluetoothService> services;

  late BluetoothDevice targetDevice;
  late BluetoothCharacteristic receiveChar;
  late BluetoothCharacteristic writeChar;

  late Stream<List<int>> stream;

  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  String connectionText = "";

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == Constants.TARGET_DEVICE_NAME) {
        print('DEVICE found');
        stopScan();
        setState(() {
          connectionText = "Found Target Device";
        });

        targetDevice = scanResult.device;
        connectToDevice();
      }
    }, onDone: () => stopScan());
  }

  stopScan() {
    flutterBlue.stopScan();
  }

  connectToDevice() async {
    if(targetDevice == null){
      _Pop();
      return;
    }

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() {
    if(targetDevice == null){
      _Pop();
      return;
    }
    targetDevice.disconnect();

    setState(() {
      connectionText = "Device Disconnected";
    });
  }

  discoverServices() async {
    if (targetDevice == null) return;

    services = await targetDevice.discoverServices();
    for (var service in services) {
      // do something with service
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Constants.CHARACTERISTIC_UART_RECIEVE) {
            c.setNotifyValue(!c.isNotifying);
            //writeData("Hi there, CircuitPython");
            receiveChar = c;
            stream = c.value;
            setState(() {
              sensorPageVM.setIsReady(true);
              connectionText = "All Ready with ${targetDevice.name}";
            });
          }
        }
      }
    }

    for (var service in services) {
      // do something with service
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Constants.CHARACTERISTIC_UART_SEND) {
            //characteristic.setNotifyValue(!characteristic.isNotifying);
            writeChar = c;
            //writeData("Hi there, CircuitPython");
          }
        }
      }
    }
  }

  writeData(String data) {
    if (receiveChar == null) return;

    List<int> bytes = utf8.encode(data);
    receiveChar.write(bytes);
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
        body: Column(
          children: [
            SizedBox(
                height: 450,
                child: !sensorPageVM.getIsReady() ? const Center(
                  child: Text("Connecting...", style: TextStyle(fontSize: 24, color: Colors.blue),),
                ) : StreamBuilder<List<int>>(
                  stream: stream,
                  builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.active) {
                      readData(snapshot);
                      return SafeArea(
                        child: Scaffold(
                          body: SfCartesianChart(
                            //crosshairBehavior: _crosshairBehavior,
                            legend: Legend(isVisible: true),
                            //zoomPanBehavior: _zoomPanBehavior,
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
                      );
                    } else { return const Text('Check the stream'); }
                  },
                )
            ),
            Wrap(
              direction: Axis.vertical,
              children: const <Widget>[
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Rate of force (RFD): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Time to peak (TTP): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Force impulse: 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Peak force: 0'
                    )
                ),
              ],
            ),
          ],
        ),

        floatingActionButton:Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed:  initGo,
                  child: const Text('START'),
                )
            ),
          ],
        ),

      ),
    );
  }

  void readData(AsyncSnapshot<List<int>> snapshot) {
    var currentValue = _dataParser(snapshot.data!);
    var tag = currentValue.split(':');
    switch(tag[0]){
      case 'RF': {
        double tmpDoubleR = double.parse(tag[1]);
        sensorPageVM.getRightFootArray().add(tmpDoubleR);
      }
      break;
      case 'LF': {
        double tmpDoubleL = double.parse(tag[1]);
        sensorPageVM.getLeftFootArray().add(tmpDoubleL);
      }
      break;
      case 'D' :{
        testUpdateSetState();
      }
      break;
      default:{
        print('No data to read');
      }
      break;
    }
  }
  void testUpdateSetState() {

    List<LiveData> tmpLeft = _getChartDataLeft();
    sensorPageVM.setLeftChartData(_getChartDataLeft());
    sensorPageVM.setRightChartData(_getChartDataRight());

    print('Left length: ${sensorPageVM.getLeftChartData().length}');
    print('Right length: ${sensorPageVM.getRightChartData().length}');
  }
  List<LiveData> _getChartDataLeft (){
    List<LiveData> tmpLeftList = <LiveData>[];
    for(int i = 0; i < sensorPageVM.getLeftFootArray().length; i++){
      print("Left: ${sensorPageVM.getLeftFootArray()[i]}");
      tmpLeftList.add(LiveData(
          time: i,
          force: sensorPageVM.getLeftFootArray()[i]));
      print("Index: $i");
      print("-----------");
    }
    return tmpLeftList;
  }

  List<LiveData> _getChartDataRight (){
    List<LiveData> tmpRightList = <LiveData>[];
    for(int i = 0; i < sensorPageVM.getRightFootArray().length; i++){
      print("Right: ${sensorPageVM.getRightFootArray()[i]}");
      tmpRightList.add(LiveData(
          time: i,
          force: sensorPageVM.getRightFootArray()[i]));
      print("Index: $i");
      print("-----------");
    }
    return tmpRightList;
  }

  /// Updates the chart
  List<SplineSeries<LiveData, int>> _getUpdateSeries() {
    return <SplineSeries<LiveData, int>>[
      SplineSeries<LiveData, int>(
        dataSource: sensorPageVM.getLeftChartData()!,
        width: 2,
        name: 'Left foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesLeftController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
      SplineSeries<LiveData, int>(
        dataSource: sensorPageVM.getRightChartData()!,
        width: 2,
        name: 'Right foot',
        onRendererCreated: (ChartSeriesController controller) {
          _chartSeriesRightController = controller; //Updates the chart live
        },
        xValueMapper: (LiveData livedata, _) => livedata.time,
        yValueMapper: (LiveData livedata, _) => livedata.force,
      ),
    ];
  }

  void flushData() async
  {
    //receiveChar = null;
    sensorPageVM.flushData();
    sensorPageVM.getTimes().clear();
  }


  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit
    flushData();

    String test = '\n';
    List<int> bytes = utf8.encode(test);
    await writeChar.write(bytes);
  }


}
