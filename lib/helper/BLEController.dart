import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/model/movesense.dart';
import 'package:startblock/model/sensor.dart';

import '../model/timestamp.dart';
class BLEController extends ChangeNotifier {
  static final _instance = BLEController._internal();

  factory BLEController()
  {
    return _instance;
  }

  BLEController._internal();

  List<Data> leftFoot = <Data>[];
  List<Data> rightFoot = <Data>[];
  late List<Movesense> movesenseData = <Movesense>[];
  List<Timestamp> timestamps = <Timestamp>[];
  late List<Timestamp> timestampArrivalTime = <Timestamp>[];

  FlutterBlue flutterBlue = FlutterBlue.instance;
  FlutterBlue movesenseBlue = FlutterBlue.instance;
  late StreamSubscription<ScanResult> scanSubScription;
  late StreamSubscription<ScanResult> scanSubMovesense;
  late StreamSubscription<List<int>>? streamSubscription;
  late StreamSubscription<List<int>>? streamSubMovesense;

  late List<BluetoothService> services;
  late List<BluetoothService> servicesMovesense;

  bool isNotStarted = false;
  bool isReady = false;
  List <int> time = <int>[];
  late BluetoothDevice? targetDevice = null,
      targetMovesenseDevice = null;
  late BluetoothCharacteristic receiveChar;
  late BluetoothCharacteristic writeChar, testChar;
  late List<int> serverTime = <int>[];
  late List<int> clientSendTime = <int>[];
  late List<int> clientRecieveTime = <int>[];

  late List<num> listSyncedTime = <num>[];
  late List<num> listRTT = <num>[];
  late List<num> tMaxList = <num>[];
  late List<num> tMinList = <num>[];
  late List<num> timeSyncOffsets = <num>[];
  late num timeSend, timeServer, timeRecieve, syncedTime, RTT, RTT_mean,
      latestMeasure, cristianTimeOffset, offsetMean, marzulloTimeOffset,
      lastServerTime, marzulloCreationTime, startSampleTime, stopSampleTime ;
  int _timeSyncCounter = 0;

  late Timer _timeSyncTimer;
  int _timeStampCounter = 0;

  startScan() async {
    scanSubScription = flutterBlue.scan().listen((scanResult) async {
      if (scanResult.device.name == Constants.TARGET_DEVICE_NAME_TIZEZ) {
        print("Found device");
        targetDevice = scanResult.device;
        await stopScan();
      }
    });
  }
  stopScan() {
    print("Stopping subscription");
    flutterBlue.stopScan();
    scanSubScription.cancel();
    connectToDevice();
  }

  connectToDevice() async {
    if (targetDevice == null) {
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
    _timeSyncTimer.cancel();

    flutterBlue.stopScan();
    scanSubScription.cancel();

    _timeSyncTimer.cancel();
    streamSubscription?.cancel();
    await targetDevice?.disconnect();

    isReady = false;

    await targetMovesenseDevice?.disconnect();
    streamSubMovesense?.cancel();
    stopMoveSenseSample();
    notifyListeners();
    print("Disconnected");
  }

  discoverServices() async {
    if (targetDevice == null) return;

    services = (await targetDevice?.discoverServices())!;
    for (var service in services) {
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
      if (service.uuid.toString() == Constants.SERVICE_UART) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == Constants.CHARACTERISTIC_UART_SEND) {
            writeChar = c;
            sendTimeSyncRequest(); //As soon as device is connected to micro:bit - Time Sync immediately
            _timeSyncTimer = Timer.periodic(Duration(minutes: 10), (timer) {
              isNotStarted = false;
              notifyListeners();
              sendTimeSyncRequest();
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
  void flushKrille() {
    _timeStampCounter = 0;
    _timeSyncCounter = 0;
    offsetMean = 0;
    listRTT.clear();
    timeSyncOffsets.clear();
    serverTime.clear();
    clientSendTime.clear();
    clientRecieveTime.clear();
    tMaxList.clear();
    tMinList.clear();
    listSyncedTime.clear();
  }

  void flushData() async
  {
    leftFoot.clear();
    rightFoot.clear();
    timestamps.clear();
    movesenseData.clear();
    timestampArrivalTime.clear();
  }


  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit

    isNotStarted = false;
    notifyListeners();
    flushData();
    startMovesenseSample(); //Starts a subscription to Movesense Accelerometer.
    String test = 'Start\n';
    List<int> bytes = utf8.encode(test);
    try {
      startSampleTime = DateTime.now().millisecondsSinceEpoch;
      print('Start time: $startSampleTime');
      await writeChar.write(bytes);
    } catch (error) {
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  void readDataTest(List<int> event) {
    var currentValue = _dataParser(event);
    var tag = currentValue.split(':');
    switch (tag[0]) {
      case 'RF':
        {

          double tmpDoubleR = double.parse(tag[1]);
          print('RF ${tmpDoubleR.toString()}');
          rightFoot.add(Data(0, tmpDoubleR));
        }
        break;
      case 'LF':
        {
          timestampArrivalTime.add(Timestamp(
              time: DateTime.now().millisecondsSinceEpoch
          ));
          double tmpDoubleL = double.parse(tag[1]);
          print('LF ${tmpDoubleL.toString()}');
          leftFoot.add(Data(0, tmpDoubleL));
        }
        break;
      case 'T':
        {
          leftFoot[_timeStampCounter].setTime(int.parse(tag[1]));
          rightFoot[_timeStampCounter].setTime(int.parse(tag[1]));
          timestamps.add(Timestamp(
              time: int.parse(tag[1])
          ));
          _timeStampCounter++;
        }
        break;
      case 'D' :
        {
          print('DONE');
          stopMoveSenseSample();
          _timeStampCounter = 0;
          print(tag[1]);
          movesenseData.forEach((element)
          {
            print('${element.timestamp}');
            print('${element.mAcc}');
            print("\n");
          });
          isNotStarted = true;
          stopSampleTime = DateTime.now().millisecondsSinceEpoch;
          notifyListeners();
        }
        break;
      case 'S' ://Time sync. recieve time stamp from micro:bit
        {
          clientRecieveTime.add(DateTime
              .now()
              .millisecondsSinceEpoch);
          timeSync(int.parse(tag[1]));
        }
        break;
      case 'SM'://mibro:bit indicates when Movesense subscription should be cancelled.
        {
          stopMoveSenseSample();
        }
        break;
      case 'FS'://False start
        {
          isNotStarted = true;
          stopMoveSenseSample();
          notifyListeners();
        }
        break;
      default:
        {
          print('No data to read');
        }
        break;
    }
  }
///Method to re-send time syncing and check how many times a time sync request has been made.
  void timeSync(int data) {
    serverTime.add(data);
    _timeSyncCounter++;
    if (_timeSyncCounter < Constants.LIST_LEN) {
      sendTimeSyncRequest();
    }
    else if (_timeSyncCounter == Constants.LIST_LEN) {
      if (isReady == false) {
        isReady = true;
        notifyListeners();
      }
      if (isNotStarted == false) {
        isNotStarted = true;
        notifyListeners();
      }
      calculateTimeSync();
      _timeSyncCounter = 0;
    }
  }
  ///Method to send time sync request over BLE
  void sendTimeSyncRequest() async
  {
    print('Time to send');
      String test = "TS\n";
      List<int> bytes = utf8.encode(test);
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      clientSendTime.add(currentTime);
      try {
        await writeChar.write(bytes);
      } catch (error) {
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
      }
  }
  ///Calculates time sync offsets for Cristian's algorithm and Marzullo's algorithm.
  void calculateTimeSync() {
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
      cristianTimeOffset = (clientSendTime[i] - serverTime[i]) +
          ((clientRecieveTime[i] - clientSendTime[i]) / 2);
      timeSyncOffsets.add(cristianTimeOffset);
      print("Offset: ${cristianTimeOffset}");
      //print(currentTime - (clientSendTime[i] - serverTime[i]));
    }
    num sum2 = 0;
    for (int i = 0; i < timeSyncOffsets.length; i++) {
      sum2 += timeSyncOffsets[i];
    }
    RTT_mean = sum / listRTT.length;
    offsetMean = sum2 / timeSyncOffsets.length;
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

    for (int i = 0; i < Constants.LIST_LEN; i++) {
      tMaxList.add(clientSendTime[i] - serverTime[i]);
      tMinList.add(clientRecieveTime[i] - serverTime [i]);
    }

    print("----------Marzullo T1 - T2------------");
    for (int i = 0; i < tMaxList.length; i++) {
      print(tMaxList[i]);
    }
    print("----------Marzullo T3 - T2------------");
    for (int i = 0; i < tMinList.length; i++) {
      print(tMinList[i]);
    }

    num maxVal = tMaxList.reduce((current, next) =>
    current < next
        ? current
        : next);
    num minVal = tMinList.reduce((current, next) =>
    current > next
        ? current
        : next);
    num timeOffset2 = (maxVal + minVal) / 2;

    print("Offset marzullo: $timeOffset2");
    marzulloTimeOffset = timeOffset2;

    /** Save the time when the marzullo offset was created
     *
     */
    marzulloCreationTime = DateTime.now().millisecondsSinceEpoch;
    print('Marzullo Creation Time: ${marzulloCreationTime.toString()}');

    /**
     * Saves the last servertime.
     */
    lastServerTime = serverTime.last;
    print('Last Server Time: ${lastServerTime.toString()}');


    flushKrille();
  }

  ///Send method to set threshold value to the micro:bit over BLE
  void sendSetThresh(String val) async
  {
    print("Setting Thresh");
    String test = "T$val\n";
    List<int> bytes = utf8.encode(test);
    int currentTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    clientSendTime.add(currentTime);
    try {
      await writeChar.write(bytes);
    } catch (error) {
      print(error);
    }
  }
  ///Scanning method for Movesense BLE
  void startScanMovesense() async {
    scanSubScription = flutterBlue.scan().listen((scanResult) async {
      print('Device: ${scanResult.device.name}');
      if (scanResult.device.name == Constants.MOVESENSE_DEVICE_NAME) {
        print("Found device");
        targetMovesenseDevice = scanResult.device;
        await stopScanMovesense();
      }
    });
  }

  stopScanMovesense() {
    print("Stopping subscription");
    flutterBlue.stopScan();
    scanSubScription.cancel();
    connectToMovesense();
  }

  connectToMovesense() async {
    if (targetMovesenseDevice == null) {
      print('No movesense device');
      return;
    }
    await targetMovesenseDevice?.connect();
    print('DEVICE CONNECTED');
    discoverMovesenseServices();
  }

  discoverMovesenseServices() async {
    if (targetMovesenseDevice == null) {
      print('No services');
      return;
    }

    servicesMovesense = (await targetMovesenseDevice?.discoverServices())!;
    print('Look after movesense services');
    for (var service in servicesMovesense) {
      // do something with service
      print('Serivce: ${service.uuid.toString()}');
      if (service.uuid.toString() == Constants.MOVESENSE_SERVICE) {
        print('service send');
        for (var c in service.characteristics) {
          print('Char send: ${c.uuid.toString()}');
          if (c.uuid.toString() == Constants.MOVESENSE_SEND) {
            print('MOVESENSE SEND: ${c}');
            testChar = c;
          }
        }
      }
    }

    for (var service in servicesMovesense) {
      // do something with service
      if (service.uuid.toString() == Constants.MOVESENSE_SERVICE) {
        for (var c in service.characteristics) {
          print('Receive char: ${c.uuid.toString()}');
          if (c.uuid.toString() == Constants.MOVESENSE_DATA) {
            print('Char: ${c.uuid.toString()}');
            await c.setNotifyValue(!c.isNotifying);
            streamSubMovesense = c.value.listen((event) {
              readMoveSenseData(event);
            });
          }
        }
      }
    }
  }
  ///Send method to stop Movesense accelerometer subscription over BLE
  void stopMoveSenseSample() async
  {
    List<int> bytes = [2, 99]; //2 = Stop subscription
    print('Stopping subscription');
    try {
      await testChar.write(bytes);
    } catch (error) {
      print('Can not send to movesense');
      print(error.toString());
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }
  ///Send method to start Movesense accelerometer subscription over BLE
  void startMovesenseSample() async
  {
    // 1, 99/Meas/Acc/208
    List<int> bytes = [
      1,// 1 = Start subscription
      99,
      47,
      77,
      101,
      97,
      115,
      47,
      65,
      99,
      99,
      47,
      50,
      48,
      56
    ]; //Starting subscription

    print('Time to sample');
    try {
      await testChar.write(bytes);
    } catch (error) {
      print('Can not send to movesense');
      print(error.toString());
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  ///Converts byte array to a float value
  _convertByteToDouble(List<int> data) {
    var bytes = Uint8List.fromList(data);
    var byteData = ByteData.sublistView(bytes);
    double x = byteData.getFloat32(0);
    return x;
  }
  ///Reads array of byte data from Movesense subscription
  ///Timestamping when data arrived. Used for single clock time sync.
  ///Converts byte-data to a float value for every axis
  ///Summerize all the accelerometer forces using Pythagoras to get an accelerometer value.
  readMoveSenseData(List<int> event) {
    int currentTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    var response = event[0];
    var reference = event[1];
    if (response == 2 && reference == 99) {
      List<int> array = [event[2], event[3], event[4], event[5]];
      var bytes = Uint8List.fromList(array);
      var byteData = ByteData.sublistView(bytes);
      int timeStamp = byteData.getUint32(0, Endian.little);
      //Accelerometer
      var Xacc = _convertByteToDouble([event[9], event[8], event[7], event[6]]);
      var Yacc = _convertByteToDouble(
          [event[13], event[12], event[11], event[10]]);
      var Zacc = _convertByteToDouble(
          [event[17], event[16], event[15], event[14]]);
      var acc = sqrt(pow(Xacc, 2) + pow(Yacc, 2) + pow(Zacc, 2));
      movesenseData.add(Movesense(timeStamp, acc, currentTime));
    }
  }
}

