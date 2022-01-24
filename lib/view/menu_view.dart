import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:startblock/view/find_device_view.dart';
import 'package:startblock/view/history_list_view.dart';
import 'package:startblock/view/sensor_view.dart';
import 'package:startblock/view/tmp_view.dart';
import 'package:startblock/view_model/home_view_model.dart';
import 'dart:async';

import 'package:startblock/view_model/menu_view_model.dart';
class MenuScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var menuData = MenuViewModel();
    return  Scaffold(
      appBar: AppBar(
        title: Text(menuData.menuTitle),
      ),
      body: Center(

      ),
        floatingActionButton:
        Wrap(
          direction: Axis.vertical,
          children: <Widget>[
              Container(
                  margin:const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FindDevicesScreen()),
                      );
                    },
                    child: const Text('Connect'),
                  )
              ),
              Container(
                  margin:const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()),
                      );
                    },
                    child: const Text('History'),
                  )
              ),
          ],
        )
    );
  }

}
