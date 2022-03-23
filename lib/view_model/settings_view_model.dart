import 'package:flutter/cupertino.dart';

import '../helper/BLEController.dart';

class SettingsViewModel{
  BLEController _bleController = BLEController();
  void setThreshHold(String val) async{
    _bleController.sendSetThresh(val);
  }
}

