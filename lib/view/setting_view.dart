import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startblock/helper/BLEController.dart';
import 'package:startblock/view_model/settings_view_model.dart';

import '../model/sensor.dart';
class SettingScreen extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}
class _SettingState extends State<SettingScreen> {
  SettingsViewModel settingVM = SettingsViewModel();
  late TextEditingController controller;
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
        onTap: ()=> FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: controller,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Set False start threshold (N)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ]
                  ),
                ),
                ElevatedButton(onPressed:(){
                  if(controller.text.isEmpty)
                    {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a "
                          "threshold value.")));
                    }
                  else
                    {
                      settingVM.setThreshHold(controller.text);
                      controller.clear();
                    }
                }
                , child: Text("Set threshold")
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child:const Text("Set threshold value to zero if you want to turn off the False start function.\n"
                      "The function is initially set to off when the system starts.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
