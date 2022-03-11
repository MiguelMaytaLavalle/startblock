import 'dart:async';
import 'dart:math';
import 'dart:convert' show jsonEncode, utf8;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:gallery_saver/gallery_saver.dart';


class MicrobitScreen extends StatefulWidget {
  @override
  _MicrobitState createState() => _MicrobitState();
}

class _MicrobitState extends State<MicrobitScreen> {
  var sensorPageVM = SensorPageViewModel();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;
  late StreamSubscription<List<int>>? streamSubscription;
  late List<BluetoothService> services;

  late BluetoothDevice? targetDevice = null;
  late BluetoothCharacteristic receiveChar;
  late BluetoothCharacteristic writeChar;

  late ChartSeriesController _chartSeriesRightController;
  late ChartSeriesController _chartSeriesLeftController;
  late TextEditingController controller;
  String connectionText = "";
  String name = '';
  bool isNotStarted = true;
  List <int> time = <int>[];
  late List<int> serverTime = <int>[];
  late List<int> clientSendTime = <int>[];
  late List<int> clientRecieveTime = <int>[];
  late List<num> listSyncedTime = <num>[];
  late List<num> listRTT = <num>[];
  late List<num> tMaxList = <num>[];
  late List<num> tMinList = <num>[];
  late List<num> krilleOffsets = <num>[];
  late num timeSend, timeServer, timeRecieve, syncedTime, RTT, RTT_mean,latestMeasure, timeOffset,offsetMean;
  int _krilleCounter = 0;
  double _sampleFrequency = 100;
  late Timer _krilleTimer;

  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
    startScan();
  }

  @override
  void dispose(){
    _cameraController.dispose();
    disconnectFromDevice();
    super.dispose();
  }


  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    //setState(() => _isLoading = false);
    //setState(() => sensorPageVM.setIsLoading(false));
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      await GallerySaver.saveVideo(file.path);
/*      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path),
      );*/
      //Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  startScan() async{
    controller = TextEditingController();
    setState(() {
      connectionText = "Start Scanning";
    });
    scanSubScription = flutterBlue.scan().listen((scanResult) async{
      if (scanResult.device.name == Constants.TARGET_DEVICE_NAME_TIZEZ) {
        print("Found device");
        setState(() {
          connectionText = "Found Target Device";
        });
        targetDevice = scanResult.device;
        await stopScan();
      }
    });
  }

  stopScan(){
    print("Stopping subscription");
    flutterBlue.stopScan();
    scanSubScription.cancel();
    connectToDevice();
  }

  connectToDevice() async {
    if(targetDevice == null){
      _pop();
      return;
    }

    setState(() {
      connectionText = "Device Connecting";
    });

    await targetDevice?.connect();
    print('DEVICE CONNECTED');
    setState(() {
      connectionText = "Device Connected";
    });

    discoverServices();
  }

  disconnectFromDevice() async {
    if (targetDevice == null) {
      _pop();
      return;
    }
    _krilleTimer.cancel();
    streamSubscription?.cancel();
    await targetDevice?.disconnect();
    print("Disconnected");
  }

  discoverServices() async {
    if (targetDevice == null) return;

    services = (await targetDevice?.discoverServices())!;
    for (var service in services) {
      // do something with service
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Constants.CHARACTERISTIC_UART_RECIEVE) {
            await c.setNotifyValue(!c.isNotifying);
            streamSubscription = c.value.listen((event) {
              readDataTest(event);
            });
            setState(() {
              //sensorPageVM.setIsReady(true);
              connectionText = "All Ready with ${targetDevice?.name}";
              //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(connectionText)));
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
            sendKrille(); //As soon as device is connected to micro:bit - Time Sync immediately
            _krilleTimer = Timer.periodic(Duration(minutes: 10), (timer) {
                sendKrille();
            });
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

  _pop() {
    Navigator.of(context).pop(true);
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: _onWillPop,
      //child: _isLoading ? Container(
      child: sensorPageVM.getIsLoading() ? Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),

        ),
      ):Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                //onPressed: () => _recordVideo(),
                onPressed: () => initGo(),
              ),
            ),
          ],
        ),
      ),
    );


    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(),
              ),
            ),
          ],
        ),
      );
    }

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
          time: time[i],
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
          time: time[i],
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
    _krilleCounter = 0;
    offsetMean = 0;
    listRTT.clear();
    krilleOffsets.clear();
    serverTime.clear();
    clientSendTime.clear();
    clientRecieveTime.clear();
  }


  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit

    setState(() {
      isNotStarted = false;
    });
    flushData();
    String test = 'Start\n';
    List<int> bytes = utf8.encode(test);
    try{
      await writeChar.write(bytes);
      _recordVideo();
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
      case 'T':{
        time.add(int.parse(tag[1]));
      }
      break;
      case 'D' :{
        //testUpdateSetState();

        print(tag[1]);
        /*
        setState(() {
          isNotStarted = true;
        });
         */
      }
      break;
      case 'S' :{
        clientRecieveTime.add(DateTime.now().millisecondsSinceEpoch);
        krillesMetod(int.parse(tag[1]));
      }
      break;
      case "Frequency" :{
        _sampleFrequency = double.parse(tag[1]);
        print("Freq : $_sampleFrequency");
      }
      break;
      default:{
        print('No data to read');
      }
      break;
    }
  }
  void krillesMetod(int data){
    serverTime.add(data);
    _krilleCounter++;
    if(_krilleCounter < Constants.LIST_LEN)
    {
      sendKrille();
    }
    else if(_krilleCounter == Constants.LIST_LEN)
    {
      if(sensorPageVM.getIsReady() == false){
        setState((){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(connectionText)));
          sensorPageVM.setIsReady(true);
          sensorPageVM.setIsLoading(false);
        });
      }
      calculateKrilles();
      _krilleCounter = 0;
    }
  }
  void sendKrille() async
  {
    print('Time to send');
    String test = "TS\n";
    List<int> bytes = utf8.encode(test);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    clientSendTime.add(currentTime);
    try{
      await writeChar.write(bytes);
    }catch(error){
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error synchronizing time.")));
    }
  }
  void calculateKrilles(){
    /**
     * Calculate Cristian's RTT Value
     */
    for(int i = 0; i < Constants.LIST_LEN; i++)
    {
      timeSend = clientSendTime[i];
      timeServer = serverTime[i];
      timeRecieve = clientRecieveTime[i];
      RTT = (timeRecieve-timeSend);
      listRTT.add(RTT);
      syncedTime = (timeServer+(timeRecieve-timeSend)/2);
      listSyncedTime.add(syncedTime);
      //timeError = (timeSend - timeServer) + ((timeRecieve - timeServer)/2);
    }
    /**
     * Calculate Cristian's RTT-mean value
     */
    num sum = 0;
    for(int i = 0; i < listRTT.length; i++)
    {
      sum += listRTT[i];
    }
    /**
     * Caluclate Cristian's offset Value
     */
    print("------------Krille Offsets------------");
    for(int i = 0; i < Constants.LIST_LEN; i++)
    {
      timeOffset = (clientSendTime[i] - serverTime[i]) + ((clientRecieveTime[i] - clientSendTime[i])/2);
      krilleOffsets.add(timeOffset);
      print("Offset: ${timeOffset}");
      //print(currentTime - (clientSendTime[i] - serverTime[i]));
    }
    num sum2 = 0;
    for(int i = 0; i < krilleOffsets.length; i++)
    {
      sum2 += krilleOffsets[i];
    }
    RTT_mean = sum/listRTT.length;
    offsetMean = sum2/krilleOffsets.length;
    latestMeasure = syncedTime;
    //print("RTT Mean: $RTT_mean");
    print("Offset mean: $offsetMean");
    /*
    print("-----------Krille RTT-----------");
    for(int i = 0; i < listRTT.length; i++)
    {
      print(listRTT[i]);
    }
     */
    /**
     * Calculate offset with Marzullo's Algorithm
     */
    /*
    for(int i = 0; i < Constants.LIST_LEN; i++)
    {
      tMaxList.add(clientSendTime[i] - serverTime[i]);
      tMinList.add(clientRecieveTime[i] - serverTime [i]);
    }
    print("----------Marzullo T1 - T2------------");
    for(int i = 0; i < tMaxList.length;  i++)
    {
      print(tMaxList[i]);
    }
    print("----------Marzullo T3 - T2------------");
    for(int i = 0; i < tMinList.length;  i++)
    {
      print(tMinList[i]);
    }
    num maxVal = tMaxList.reduce((current, next) => current < next ? current : next);
    num minVal = tMinList.reduce((current, next) => current > next ? current : next);
    num timeOffset2 = (maxVal + minVal)/2;
     */
    //print("Offset $timeOffset2");

    flushData();
  }
  void sendConfigRequest() async
  {
    print('Config request');
    String test = "Conf\n";
    List<int> bytes = utf8.encode(test);
    try{
      await writeChar.write(bytes);
    }catch(error){
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error getting configs.")));
    }
  }
}



/*Scaffold(
        appBar: AppBar(
          title:Text('${targetDevice?.name}'),
        ),
        body:
        Column(
          children: [
            SizedBox(
                height: 500,
                child:  StreamBuilder<BluetoothDeviceState>(
                  stream: targetDevice?.state,
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.active) {
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
                                interval: 1000, //1000ms between two timestamps equals a second
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
                  onPressed: isNotStarted ? sendKrille: null,
                  child: const Text('Krille'),
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
      ),*/

