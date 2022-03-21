import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:startblock/helper/BLEController.dart';

import '../model/sensor.dart';
class SettingScreen extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<SettingScreen> {
  BLEController bleController = BLEController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bleController.addListener(updateDetails);
  }
  void updateDetails(){

    if(mounted){
      setState((){});
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

    );
  }
}
