import 'package:flutter/material.dart';
import 'package:startblock/db/database_helper.dart';
import 'package:startblock/model/history.dart';
import 'package:startblock/model/livedata.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;

class Test extends StatelessWidget {
  // This widget is the root of your application.
  final History? history;

  const Test({
    Key? key,
    this.history,
}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: TestPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _formKey = GlobalKey<FormState>();
  late List<LiveData> chartData;
  late ChartSeriesController _chartSeriesController;

  @override
  void initState() {
    chartData = getChartData();
    Timer.periodic(const Duration(seconds: 1), updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SfCartesianChart(
                series: <LineSeries<LiveData, int>>[
                  LineSeries<LiveData, int>(
                    onRendererCreated: (ChartSeriesController controller) {
                      _chartSeriesController = controller;
                    },
                    dataSource: chartData,
                    color: const Color.fromRGBO(192, 108, 132, 1),
                    xValueMapper: (LiveData sales, _) => sales.time,
                    yValueMapper: (LiveData sales, _) => sales.speed,
                  )
                ],
                primaryXAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    edgeLabelPlacement: EdgeLabelPlacement.shift,
                    interval: 3,
                    title: AxisTitle(text: 'Time (seconds)')),
                primaryYAxis: NumericAxis(
                    axisLine: const AxisLine(width: 0),
                    majorTickLines: const MajorTickLines(size: 0),
                    title: AxisTitle(text: 'Internet speed (Mbps)'))

            ),

          floatingActionButton:
          Wrap(
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
                margin:const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: addOrUpdateHistory,
                  child: const Text('Test Save'),
                )
            ),
          ],
        ),

        )

    );
  }

  void addOrUpdateHistory() async{
      await addHistory();
  }

  Future addHistory() async {
    final history =  History(
      dateTime: DateTime.now(),
      name: 'Ricardo',
      liveData: getChartData(),
    );

      await HistoryDatabase.instance.create(history);
  }

  int time = 19;
  void updateDataSource(Timer timer) {
    chartData.add(LiveData(time: time++, speed: (math.Random().nextInt(60) + 30)));
    chartData.removeAt(0);
    _chartSeriesController.updateDataSource(
        addedDataIndex: chartData.length - 1, removedDataIndex: 0);
  }
  List<LiveData> getChartData() {
    return <LiveData>[
      LiveData(time: 0, speed: 42),
      LiveData(time: 1, speed: 47),
      LiveData(time: 2, speed: 43),
      LiveData(time: 3, speed: 49),
      LiveData(time: 4, speed: 54),
      LiveData(time: 5, speed: 41),
      LiveData(time: 6, speed: 58),
      LiveData(time: 7, speed: 51),
      LiveData(time: 8, speed: 98),
      LiveData(time: 9, speed: 41),
      LiveData(time: 10, speed: 53),
      LiveData(time: 11, speed: 72),
      LiveData(time: 12, speed: 86),
      LiveData(time: 13, speed: 52),
      LiveData(time: 14, speed: 94),
      LiveData(time: 15, speed: 92),
      LiveData(time: 16, speed: 86),
      LiveData(time: 17, speed: 72),
      LiveData(time: 18, speed: 18)

    ];
  }
}
