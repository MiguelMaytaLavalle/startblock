import '../helper/BLEController.dart';

class SettingsViewModel{
  final BLEController _bleController = BLEController();

  /// Calls function from BLEController to send UART
  /// message to micro:bit. Sets the threshold on micro:bit.
  void setThreshHold(String val) async{
    _bleController.sendSetThresh(val);
  }

  void connectToMovesense(){
    _bleController.startScanMovesense();
  }
  void sendMoveSense()
  {
    _bleController.startMovesenseSample();
  }
}

