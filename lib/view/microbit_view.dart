import 'dart:async';
import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  late TextEditingController controller;
  String connectionText = "";
  String name = '';
  bool isNotStarted = true;

  @override
  void initState() {
    super.initState();
    startScan();
  }

  startScan() {
    controller = TextEditingController();
    setState(() {
      connectionText = "Start Scanning";
    });

    scanSubScription = flutterBlue.scan().listen((scanResult) {
      if (scanResult.device.name == Constants.TARGET_DEVICE_NAME) {
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
    if (targetDevice == null) {
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
            await c.setNotifyValue(!c.isNotifying);
            c.value.listen((event) {
              readDataTest(event);
            });
            stream = c.value;
            setState(() {
              sensorPageVM.setIsReady(true);
              connectionText = "All Ready with ${targetDevice.name}";
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(connectionText)));
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
                      //readData(snapshot);
                      return SafeArea(
                        child: Scaffold(
                          appBar: AppBar(
                            title:Text('${targetDevice.name}'),
                          ),
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
                  onPressed: isNotStarted ? discoverServices: null,
                  child: const Text('RECONNECT'),
                )
            ),

            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {

                    if(sensorPageVM.getLeftChartData().length == 0 &&
                        sensorPageVM.getRightChartData().length == 0){
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please start a run")));
                    }else{
                      final name = await openDialog();
                      if(name == null || name.isEmpty) return;
                      setState(() => this.name = name);
                      addHistory();
                    }

                  },
                  child: const Icon(Icons.save_alt),
                )
            ),
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: isNotStarted ? initGo: null,
                  child: const Text('START'),
                )
            ),
          ],
        ),

      ),
    );
  }

  Future<String?> openDialog() => showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Enter Name'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter Name Here'),
        controller: controller,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          child: const Text('Submit'),
          onPressed: submit,
        ),
      ],
    ),
  );

  void submit(){
    Navigator.of(context).pop(controller.text );
    controller.clear();
  }

  Future addHistory() async {
      try{
        List<LiveData> leftList = sensorPageVM.getLeftChartData();
        List<LiveData> rightList = sensorPageVM.getRightChartData();
        final history =  History(
          dateTime: DateTime.now(),
          name: this.name,
          leftData: jsonEncode(leftList),
          rightData: jsonEncode(rightList),
        );
        await HistoryDatabase.instance.create(history);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved Successfully!")));
      }catch(error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
  }

  void testUpdateSetState() {

    List<LiveData> tmpLeft = _getChartDataLeft();
    sensorPageVM.setLeftChartData(_getChartDataLeft());
    sensorPageVM.setRightChartData(_getChartDataRight());
    setState(() {
      isNotStarted = true;
    });
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

    setState(() {
      isNotStarted = false;
    });
    flushData();
    String test = '\n';
    List<int> bytes = utf8.encode(test);
    try{
      await writeChar.write(bytes);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Start")));
    }catch(error){
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lost connection")));
    }

  }

  void readDataTest(List<int> event) {

    var currentValue = _dataParser(event);
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


}
