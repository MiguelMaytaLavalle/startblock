import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:startblock/view/find_device_view.dart';
import 'package:startblock/view/history_list_view.dart';
import 'package:startblock/view/microbit_view.dart';
import 'package:startblock/view/tmp_view.dart';
import 'package:startblock/view_model/menu_view_model.dart';

import 'send_email_view.dart';

class MenuScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var menuData = MenuViewModel();
    return  Scaffold(
      appBar: AppBar(
        title: Text(menuData.menuTitle),
      ),
      body: const MyStatefulWidget(),
    );
  }

}
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style =
    ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
/*          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FindDevicesScreen()),
              );
            },
            child: const Text('Connect'),
          ),
          const SizedBox(height: 30),*/
          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
            child: const Text('History'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TestScreen()),
              );
            },
            child: const Text('Test'),

          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: style,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => microbitScreen()),
              );
            },
            child: const Text('Instant'),

          ),
        ],
      ),
    );
  }
}
