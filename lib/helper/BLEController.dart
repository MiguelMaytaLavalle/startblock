import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/constant/constants.dart';
import 'package:startblock/model/livedata.dart';
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
  List<Data> leftFootEWMA = <Data>[];
  List<Data> rightFootEWMA = <Data>[];

  /*late List<Data> leftFootEWMA;
  late List<Data> rightFootEWMA;*/
  List<Timestamp> timestamps = <Timestamp>[];

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
  late List<num> krilleOffsets = <num>[];
  late num timeSend, timeServer, timeRecieve, syncedTime, RTT, RTT_mean,
      latestMeasure, timeOffset, offsetMean, marzullo;
  int _krilleCounter = 0;
  double _sampleFrequency = 100;
  late Timer _krilleTimer;
  int _counter = 0;

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
    _krilleTimer.cancel();
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
              isNotStarted = false;
              notifyListeners();
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

  void flushKrille() {
    _counter = 0;
    _krilleCounter = 0;
    offsetMean = 0;
    listRTT.clear();
    krilleOffsets.clear();
    serverTime.clear();
    clientSendTime.clear();
    clientRecieveTime.clear();
  }

  void flushData() async
  {
    //sensorPageVM.flushData();
    //sensorPageVM.getTimes().clear();
    leftFoot.clear();
    rightFoot.clear();
    timestamps.clear();
    leftFootEWMA.clear();
    rightFootEWMA.clear();
  }


  initGo() async {
    /// Reads the services and characteristics UUID for the Micro:Bit
    /// Send a GO signal to the Micro:Bit

    isNotStarted = false;
    notifyListeners();
    flushData();
    String test = 'Start\n';
    List<int> bytes = utf8.encode(test);
    try {
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
          double tmpDoubleL = double.parse(tag[1]);
          print('LF ${tmpDoubleL.toString()}');
          leftFoot.add(Data(0, tmpDoubleL));
        }
        break;
      case 'T':
        {
          leftFoot[_counter].setTime(int.parse(tag[1]));
          rightFoot[_counter].setTime(int.parse(tag[1]));
          timestamps.add(Timestamp(
              time: int.parse(tag[1])
          ));
          _counter++;
          //sensorPageModel.setTime(int.parse(tag[1]));
        }
        break;
      case 'D' :
        {
          //testUpdateSetState();
          print('DONE');
          _counter = 0;
          print(tag[1]);

          leftFoot.forEach((element) {
            print('${element.mForce}');
          });

          print('---------------------------------');

          rightFoot.forEach((element) {
            print('${element.mForce}');
          });
          isNotStarted = true;
          notifyListeners();
          /*
        setState(() {
          isNotStarted = true;
        });
         */
        }
        break;
      case 'S' :
        {
          clientRecieveTime.add(DateTime
              .now()
              .millisecondsSinceEpoch);
          krillesMetod(int.parse(tag[1]));
        }
        break;
      default:
        {
          print('No data to read');
        }
        break;
    }
  }

  void krillesMetod(int data) {
    serverTime.add(data);
    _krilleCounter++;
    if (_krilleCounter < Constants.LIST_LEN) {
      sendKrille();
    }
    else if (_krilleCounter == Constants.LIST_LEN) {
      if (isReady == false) {
        isReady = true;
        notifyListeners();
      }
      if (isNotStarted == false) {
        isNotStarted = true;
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
    int currentTime = DateTime
        .now()
        .millisecondsSinceEpoch;
    clientSendTime.add(currentTime);
    try {
      await writeChar.write(bytes);
    } catch (error) {
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
    marzullo = timeOffset2;
    flushKrille();
  }

  ///Send method to set threshold value to the micro:bit
  ///
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

    String test = '/Meas/Acc/52';
    //List<int> bytes = [1, 99, 47, 77, 101, 97, 115, 47, 65, 99, 99, 47, 53, 50];
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
            //testMove();
            //List<int> bytes = utf8.encode(test);
            //print('Bytes: ${bytes.toString()}');
            //c.write(bytes);
            //characteristic.setNotifyValue(!characteristic.isNotifying);
            /*writeChar = c;
            sendKrille(); //As soon as device is connected to micro:bit - Time Sync immediately
            _krilleTimer = Timer.periodic(Duration(minutes: 10), (timer) {
              isNotStarted = false;
              notifyListeners();
              sendKrille();
            });*/
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
            //await c.setNotifyValue(true);
            streamSubMovesense = c.value.listen((event) {
              //readDataTest(event);
              print('Movesense event: ${event}');
            });
          }
        }
      }
    }
  }

  void stopMoveSenseSample() async
  {
    List<int> bytes = [2, 99]; //Stopping subscription
    print('Stopping subscription');
    try {
      await testChar.write(bytes);
    } catch (error) {
      print('Can not send to movesense');
      print(error.toString());
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void startMovesenseSample() async
  {
    // 1, 99/Meas/Acc/208
    List<int> bytes = [
      1,
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

  readMoveSenseData(List<int> event) {
    var response = event[0];
    var reference = event[1];
    if (response == 2 && reference == 99) {
      List<int> array = [event[2], event[3], event[4], event[5]];
      var bytes = Uint8List.fromList(array);
      var byteData = ByteData.sublistView(bytes);
      int timeStamp = byteData.getUint32(0, Endian.little);
      print(timeStamp);
      //Accelerometer
      var Xacc = _convertByteToDouble([event[9], event[8], event[7], event[6]]);
      var Yacc = _convertByteToDouble(
          [event[13], event[12], event[11], event[10]]);
      var Zacc = _convertByteToDouble(
          [event[17], event[16], event[15], event[14]]);
      print(Xacc);
      print(Yacc);
      print(Zacc);

      //List<Data>_EWMAFilter(List<Data> data)
      void _EWMAFilter(List<Data> data, List<Data> listEWMA) {
        double alpha = 0.5;
        //List<Data> tempList = <Data>[];
        print("Data length: ${data.length}");

        for (int i = 0; i < data.length - 1; i++) {
          if (i == 0) {
            print('i = 0');
            print(data[i].mForce);
            //tempList.add(data[i]);
            listEWMA.add(data[i]);
          }
          else {
            print('Data force: ${data[i].mForce}');
            Data tempData = data[i];
            //tempData.mForce = alpha * data[i].getForce() + (1-alpha) * tempList[i-1].getForce();
            tempData.mForce = alpha * data[i].getForce() +
                (1 - alpha) * listEWMA[i - 1].getForce();
            print('tempData force: ${tempData.mForce}');
            //tempList.add(tempData);
            listEWMA.add(tempData);
            //print('Templist length: ${tempList.length}');
            print('Templist length: ${listEWMA.length}');
          }
        }
        //return tempList;
      }

    }
  }
}
