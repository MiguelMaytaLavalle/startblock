import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/model/livedata.dart';
import 'package:startblock/model/sensor.dart';
class BLEController extends ChangeNotifier{
  static final _instance = BLEController._internal();
  factory BLEController()
  {
    return _instance;
  }
  BLEController._internal();

  List<Data> leftFoot = [];
  List<Data> rightFoot = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;
  late StreamSubscription<List<int>>? streamSubscription;
  late List<BluetoothService> services;

  bool isNotStarted = true;
  bool isReady = false;
  List <int> time = <int>[];
  late BluetoothDevice? targetDevice = null;
  late BluetoothCharacteristic receiveChar;
  late BluetoothCharacteristic writeChar;
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
  int _counter = 0;

  startScan() async{
    scanSubScription = flutterBlue.scan().listen((scanResult) async{
      if (scanResult.device.name == Constants.TARGET_DEVICE_NAME_ZIVIT) {
        print("Found device");
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
      return;
    }
    await targetDevice?.connect();
    print('DEVICE CONNECTED');
    discoverServices();
  }

  disconnectFromDevice() async {
    if (targetDevice == null) {
      return;
    }
    _krilleTimer.cancel();
    streamSubscription?.cancel();
    isReady = false;
    await targetDevice?.disconnect();
    notifyListeners();
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
  void flushData() async
  {
    //sensorPageVM.flushData();
    //sensorPageVM.getTimes().clear();
    leftFoot.clear();
    rightFoot.clear();
    _counter = 0;
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

    isNotStarted = false;
    flushData();
    String test = 'Start\n';
    List<int> bytes = utf8.encode(test);
    try{
      await writeChar.write(bytes);
    }catch(error){
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }

  }
  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }
  void readDataTest(List<int> event) {

    var currentValue = _dataParser(event);
    var tag = currentValue.split(':');
    switch(tag[0]){
      case 'RF': {
        double tmpDoubleR = double.parse(tag[1]);
        print('RF ${tmpDoubleR.toString()}');
        rightFoot.add(Data(0,tmpDoubleR));
      }
      break;
      case 'LF': {
        double tmpDoubleL = double.parse(tag[1]);
        print('LF ${tmpDoubleL.toString()}');
        leftFoot.add(Data(0,tmpDoubleL));
      }
      break;
      case 'T':{
        leftFoot[_counter].setTime(int.parse(tag[1]));
        rightFoot[_counter].setTime(int.parse(tag[1]));
        _counter++;
        //sensorPageModel.setTime(int.parse(tag[1]));
      }
      break;
      case 'D' :{
        //testUpdateSetState();
        print('DONE');
        _counter = 0;
        print(tag[1]);
        notifyListeners();
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
      if(isReady == false){
        isReady = true;
        notifyListeners();
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
    }
  }
  void calculateKrilles() {
    /**
     * Calculate Cristian's RTT Value
     */
    for (int i = 0; i < Constants.LIST_LEN; i++) {
      timeSend = clientSendTime[i];
      timeServer = serverTime[i];
      timeRecieve = clientRecieveTime[i];
      RTT = (timeRecieve - timeSend);
      listRTT.add(RTT);
      syncedTime = (timeServer + (timeRecieve - timeSend) / 2);
      listSyncedTime.add(syncedTime);
      //timeError = (timeSend - timeServer) + ((timeRecieve - timeServer)/2);
    }
    /**
     * Calculate Cristian's RTT-mean value
     */
    num sum = 0;
    for (int i = 0; i < listRTT.length; i++) {
      sum += listRTT[i];
    }
    /**
     * Caluclate Cristian's offset Value
     */
    print("------------Krille Offsets------------");
    for (int i = 0; i < Constants.LIST_LEN; i++) {
      timeOffset = (clientSendTime[i] - serverTime[i]) +
          ((clientRecieveTime[i] - clientSendTime[i]) / 2);
      krilleOffsets.add(timeOffset);
      print("Offset: ${timeOffset}");
      //print(currentTime - (clientSendTime[i] - serverTime[i]));
    }
    num sum2 = 0;
    for (int i = 0; i < krilleOffsets.length; i++) {
      sum2 += krilleOffsets[i];
    }
    RTT_mean = sum / listRTT.length;
    offsetMean = sum2 / krilleOffsets.length;
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
}
