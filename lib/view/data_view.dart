import 'package:flutter/material.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
class DataScreen extends StatefulWidget {
  @override
  _DataState createState() => _DataState();
}

class _DataState extends State<DataScreen> {
  var sensorPageVM = SensorPageViewModel();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body:SafeArea(
        child: SingleChildScrollView(
        child:Column(
          children:[
            SfCartesianChart(
              //crosshairBehavior: _crosshairBehavior,
              legend: Legend(isVisible: true),
              //zoomPanBehavior: _zoomPanBehavior,
              //series: _getUpdateSeries(),
              primaryXAxis: NumericAxis(
                  interactiveTooltip: const InteractiveTooltip(
                    enable: true,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1000, //1000ms between two timestamps equals a second
                  title: AxisTitle(text: 'Time [S]')
              ),

              primaryYAxis: NumericAxis(
                  minimum: 0,
                  //maximum: 800,
                  interactiveTooltip: const InteractiveTooltip(
                    enable: true,
                  ),
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  title: AxisTitle(text: 'Force [N]')
              ),
            ),

            Wrap(
              direction: Axis.vertical,
              children: const <Widget>[
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Rate of force (RFD): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Time to peak (TTP): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Force impulse: 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Peak force: 0'
                    )
                ),
              ],
            ),

            SfCartesianChart(
              //crosshairBehavior: _crosshairBehavior,
              legend: Legend(isVisible: true),
              //zoomPanBehavior: _zoomPanBehavior,
              //series: _getUpdateSeries(),
              primaryXAxis: NumericAxis(
                  interactiveTooltip: const InteractiveTooltip(
                    enable: true,
                  ),
                  majorGridLines: const MajorGridLines(width: 0),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  interval: 1000, //1000ms between two timestamps equals a second
                  title: AxisTitle(text: 'Time [S]')
              ),
              primaryYAxis: NumericAxis(
                  minimum: 0,
                  //maximum: 800,
                  interactiveTooltip: const InteractiveTooltip(
                    enable: true,
                  ),
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  title: AxisTitle(text: 'Force [N]')
              ),
            ),

            Wrap(
              direction: Axis.vertical,
              children: const <Widget>[
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Rate of force (RFD): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Time to peak (TTP): 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Force impulse: 0'
                    )
                ),
                Material(
                  //margin:const EdgeInsets.all(10),
                    child: Text('Peak force: 0'
                    )
                ),
              ],
            ),

            TextButton(
              onPressed: () {  },
              child: const Icon(Icons.save),
            ),
          ],


        ),

      ),
      ),
    );
  }
}
