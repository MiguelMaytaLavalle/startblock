import 'dart:async';
import 'dart:convert' show jsonEncode, utf8;

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;

  @override
  _SensorScreenState createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  var sensorPageVM = SensorPageViewModel();
  late Stream<List<int>> stream;
  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  late ZoomPanBehavior _zoomPanBehavior;
  late CrosshairBehavior _crosshairBehavior;
  //late List<String> listKrille = <String>[];
  late List<int> serverTime = <int>[];
  late List<int> clientSendTime = <int>[];
  late List<int> clientRecieveTime = <int>[];
  late List<num> listRTT = <num>[];
  //late Timer timer;
  late List<BluetoothService> services;
  late TextEditingController controller;
  late num timeSend, timeServer, timeRecieve, RTT, RTT_mean,latestMeasure;
  late BluetoothCharacteristic sendChar;
  String name = '';
  bool isSaved = false;
  String whichSide = 'LF';

  late List<String> tmpListRight = <String>[];
  late List<String> tmpListLeft = <String>[];


  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      zoomMode: ZoomMode.xy,
      enablePanning: true,
    );
    _crosshairBehavior = CrosshairBehavior(enable: true);
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    Timer(const Duration(seconds: 15), () {
      //if (!isReady) {
      if(!sensorPageVM.getIsReady()){
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
    //List<BluetoothService> services = await widget.device.discoverServices();
    services = await widget.device.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == Constants.CHARACTERISTIC_UART_RECIEVE) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            setState(() {
              sensorPageVM.setIsReady(true);
            });
          }
        }
      }
    }

    for (var service in services) {
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Constants.CHARACTERISTIC_UART_SEND) {
            sendChar = c;
          }
        }
      }
    }

    if (!sensorPageVM.getIsReady()){
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
          title: const Text('Startblock'),
        ),
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
                      testReadDataLoss(snapshot);
                      //krillesMetod(snapshot);
                      return SafeArea(
                        child: Scaffold(
                          body: SfCartesianChart(
                            crosshairBehavior: _crosshairBehavior,
                            legend: Legend(isVisible: true),
                            zoomPanBehavior: _zoomPanBehavior,
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
                  onPressed: calculateKrilles,
                  child: const Icon(Icons.flare),
                )
            ),
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () async {
                    final name = await openDialog();
                    if(name == null || name.isEmpty) return;
                    setState(() => this.name = name);
                    addHistory();
                  },
                  child: const Icon(Icons.save_alt),
                )
            ),
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: initGo,
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
      title: Text('Enter Name'),
      content: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter Name Here'),
        controller: controller,
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          child: Text('Submit'),
          onPressed: submit,
        ),
      ],
    ),
  );

  Future<void> _startNewScan() {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to start a new measure without saving?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      isSaved = true;
                    },
                    child: const Text('No')),
                TextButton(
                    onPressed:
                      flushData,
                    child: const Text('Yes')),
              ],
            )
    );
  }

  void submit(){
    Navigator.of(context).pop(controller.text );
    controller.clear();
  }

  Future addHistory() async {
    List<LiveData> leftList = sensorPageVM.getLeftChartData();
    List<LiveData> rightList = sensorPageVM.getRightChartData();

    final history =  History(
      dateTime: DateTime.now(),
      name: this.name,
      leftData: jsonEncode(leftList),
      rightData: jsonEncode(rightList),
    );
    await HistoryDatabase.instance.create(history);
  }

  void flushData() async
  {
    print("flush");
    isSaved = false;
    sensorPageVM.getRightFootArray().clear();
    sensorPageVM.getLeftFootArray().clear();
    sensorPageVM.getTimes().clear();
    clientRecieveTime.clear();
    clientSendTime.clear();
    serverTime.clear();
  }

  ///Krilles algoritm
  /// rad 156 anropas den här metoden för att läsa in strömmen från microbiten till mobilen
  /// Tanken är att istället för att göra uträkningar först så samlar vi in allt från snapshot
  /// till en lämplig list och sen göra uträkningar när den är klar
  ///
  ///
  /**
   * AsyncSnapshot<List<int>> snapshot.data will contain data in UInt8 type
   */
  void krillesMetod(AsyncSnapshot<List<int>> snapshot){
      var c = utf8.decode(snapshot.data!);
      var x = int.tryParse(c) ?? 0; //Assign x = 0 if data is null
      serverTime.add(x);
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      clientRecieveTime.add(currentTime);
    //sensorPageVM.getRightFootArray().add(int.tryParse(currentValue) ?? 1000);
  }

  /// Efter hämtning från microbit kan man göra uträkningen här
  /// Finns en knapp på sensorview för att anropa metod
  void calculateKrilles(){
    print(clientSendTime.length);
    print(clientRecieveTime.length);
    print(serverTime.length);
    for(int i = 0; i < 30; i++)
      {
        timeSend = clientSendTime[i];
        timeServer = serverTime[i];
        timeRecieve = clientRecieveTime[i];
        RTT = timeServer+((timeRecieve-timeSend)/2);
        listRTT.add(RTT);
        print(timeRecieve - timeSend);
      }
    num sum = 0;
    for(int i = 0; i < listRTT.length; i++)
      {
        sum += listRTT[i];
      }
    RTT_mean = sum/listRTT.length;
    latestMeasure = RTT;
    print(RTT_mean);
  }

  void testUpdate() {
    for(int i = 0; i < sensorPageVM.getLeftFootArray().length; i++){
      print("Left: ${sensorPageVM.getLeftFootArray()[i]}");
      sensorPageVM.getLeftChartData().add(LiveData(
          time: i,
          force: sensorPageVM.getLeftFootArray()[i]));

    }
    for(int i = 0; i < sensorPageVM.getRightFootArray().length; i++){
      print("Right: ${sensorPageVM.getRightFootArray()[i]}");
      sensorPageVM.getRightChartData().add(LiveData(
          time: i,
          force: sensorPageVM.getRightFootArray()[i]));
      print("Index: $i");
      print("-----------");
    }

    print("DONE");
  }

  void testUpdateDataLoss() {
    print(tmpListLeft.length);
    print(tmpListRight.length);
  }


  /// Här hämtar vi data från plattan som strängar också.
  /// Vi vill göra omvandlingar efter vi har samlat in allt från respektive fot
  void readData(AsyncSnapshot<List<int>> snapshot) {
    var currentValue = _dataParser(snapshot.data!);
    /// data hantering för plattan
    ///tar emot lf först
    ///switch sats
    ///ta emot rf nästa när lf är klar.
    ///två string lists.

    var tag = currentValue.split(':');


    switch(tag[0]){
      case 'RF': {
        //print('RF: ${tag[1]}');
        //sensorPageVM.getRightFootArray().add(int.tryParse(tag[1]) ?? 0);
        double tmpDoubleR = double.parse(tag[1]);
        int tmpIntR = tmpDoubleR.toInt();
        print('LF: $tmpIntR');
        sensorPageVM.getRightFootArray().add(tmpIntR);
      }
      break;
      case 'LF': {
        //print('LF: ${tag[1]}');
        //sensorPageVM.getLeftFootArray().add(int.tryParse(tag[1]) ?? 0);
        double tmpDoubleL = double.parse(tag[1]);
        int tmpIntL = tmpDoubleL.toInt();
        print('LF: $tmpIntL');
        sensorPageVM.getRightFootArray().add(tmpIntL);
      }
      break;
      case 'D' :{
        testUpdate();
      }
      break;
      default:{
        print('No data to read');
      }
      break;
    }
  }


  void testReadDataLoss(AsyncSnapshot<List<int>> snapshot){
    var currentValue = _dataParser(snapshot.data!);

    if(currentValue == '!'){
      print('Sideswitch!');
      whichSide = 'RF';
      return;
    }else if(currentValue == 'D'){
      testUpdateDataLoss();
    }

    switch(whichSide){
      case 'RF': {
        print('Right!');
        tmpListRight.add(currentValue);
      }
      break;
      case 'LF': {
        print('Left!');
        tmpListLeft.add(currentValue);
      }
      break;
    }

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

  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit

    String test = '\n';
    List<int> bytes = utf8.encode(test);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    clientSendTime.add(currentTime);
    await sendChar.write(bytes);
    /*print(isSaved);
    if(!isSaved)
      {
        clientRecieveTime.clear();
        clientSendTime.clear();
        serverTime.clear();
        for(int i = 0; i < 30; i++){
          print("SEND $i");
          String test = '\n';
          List<int> bytes = utf8.encode(test);
          int currentTime = DateTime.now().millisecondsSinceEpoch;
          clientSendTime.add(currentTime);
          await sendChar.write(bytes);
        }
      }
    else
    {
      _startNewScan();
    }*/
  }
}

