import 'package:flutter/cupertino.dart';
import 'package:startblock/helper/BLEController.dart';

class RecordingViewModel extends ChangeNotifier{
 BLEController bleController = BLEController();

 connect() async{
   notifyListeners();
   bleController.connectToDevice();
 }
 disconnect() async{
   bleController.disconnectFromDevice();
 }
 getDeviceName(){
   var deviceName = bleController.targetDevice?.name;
   return deviceName;
 }
}
