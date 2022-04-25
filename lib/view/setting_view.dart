import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:startblock/view_model/settings_view_model.dart';
import 'package:provider/provider.dart';

/// A user can choose to adjust the false start threshold from the Setting view.
/// A user can also connect to a movesense if the user chooses to.
/// After connecting to a movesense a user can initiate an episode and record the movesense data.
///
class SettingScreen extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}
class _SettingState extends State<SettingScreen> {
  SettingsViewModel settingVM = SettingsViewModel();
  late TextEditingController controller;
  //late bool isReady = settingVM.isBleReady();
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
        child: ChangeNotifierProvider(
          create: (context) => SettingsViewModel(),
          child:Scaffold(
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
                        "The function is initially set to 100N when the system starts.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                      onPressed:(){
                        settingVM.connectToMovesense();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deez")));
                      },
                      child: Text("Connect Movesense")
                  ),
                  ElevatedButton(
                      onPressed:(){
                        settingVM.sendMoveSense();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deez")));
                      },
                      child: Text("Send Movesense")
                  ),
                  ElevatedButton(
                      onPressed:(){
                        settingVM.stopMovesense();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deez")));
                      },
                      child: Text("Stop Movesense")
                  )
                ],
              ),
            ),
          ),
        )


    );
  }
}
