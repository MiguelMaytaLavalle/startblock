import 'dart:async';
import 'package:flutter/material.dart';
import 'package:startblock/view_model/sensor_page_view_model.dart';
import 'package:camera/camera.dart';
import '../helper/BLEController.dart';
import 'package:gallery_saver/gallery_saver.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingState createState() => _RecordingState();
}

class _RecordingState extends State<RecordingScreen> {
  var sensorPageVM = SensorPageViewModel();
  BLEController bleController = BLEController();

  bool _isLoading = true;
  bool _isRecording = false;
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    bleController.addListener(updateDetails);
    _initCamera();
  }

  void updateDetails(){
    if(this.mounted){
      setState((){});
    }
  }

/*
  @override
  dispose(){
    _cameraController.dispose();
    super.dispose();
  }
*/

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
    //setState(() => sensorPageVM.setIsLoading(false));
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      await GallerySaver.saveVideo(file.path);
/*      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(filePath: file.path),
      );*/
      //Navigator.push(context, route);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }



  Future<bool> _onWillPop() {
    return showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to disconnect device and go back?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No')),
                TextButton(
                    onPressed: () {
                      bleController.disconnectFromDevice();
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Yes')),
              ],
            )
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: !bleController.isReady ? Container(
      //child: _isLoading ? Container(
      //child: sensorPageVM.getIsLoading() ? Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ):Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[

            CameraPreview(_cameraController),

            Padding(
              padding: const EdgeInsets.all(100),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(),
                //onPressed: () => initGo(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30),
              child: TextButton(
                onPressed: (){},
                child: const Text('Start'),
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor:
                    Colors.blue),
              ),
            ),

          ],

        ),

      ),
    );


    // return WillPopScope(
    //     onWillPop: _onWillPop,
    //     child:
    //     Scaffold(
    //       appBar: AppBar(
    //         /*title:Text('${bleController.targetDevice?.name}'),*/
    //       ),
    //       /*Column(
    //       children: [
    //         SizedBox(
    //             height: 500,
    //             child:  StreamBuilder<BluetoothDeviceState>(
    //               stream: targetDevice?.state,
    //               builder: (BuildContext context, snapshot) {
    //                 if (snapshot.hasError) return Text('Error: ${snapshot.error}');
    //                 if (snapshot.connectionState == ConnectionState.active) {
    //                   return SafeArea(
    //                     child: Scaffold(
    //                       body: SfCartesianChart(
    //                         //crosshairBehavior: _crosshairBehavior,
    //                         legend: Legend(isVisible: true),
    //                         //zoomPanBehavior: _zoomPanBehavior,
    //                         series: _getUpdateSeries(),
    //                         primaryXAxis: NumericAxis(
    //                             interactiveTooltip: const InteractiveTooltip(
    //                               enable: true,
    //                             ),
    //                             majorGridLines: const MajorGridLines(width: 0),
    //                             edgeLabelPlacement: EdgeLabelPlacement.shift,
    //                             interval: 1000, //1000ms between two timestamps equals a second
    //                             title: AxisTitle(text: 'Time [S]')
    //                         ),
    //
    //                         primaryYAxis: NumericAxis(
    //                             minimum: 0,
    //                             //maximum: 800,
    //                             interactiveTooltip: const InteractiveTooltip(
    //                               enable: true,
    //                             ),
    //                             axisLine: const AxisLine(width: 0),
    //                             majorTickLines: const MajorTickLines(size: 0),
    //                             title: AxisTitle(text: 'Force [N]')
    //                         ),
    //                       ),
    //                     ),
    //                   );
    //                 } else { return const Text('Check the stream'); }
    //               },
    //             )
    //         ),
    //         Wrap(
    //           direction: Axis.vertical,
    //           children: const <Widget>[
    //             Material(
    //               //margin:const EdgeInsets.all(10),
    //                 child: Text('Rate of force (RFD): 0'
    //                 )
    //             ),
    //             Material(
    //               //margin:const EdgeInsets.all(10),
    //                 child: Text('Time to peak (TTP): 0'
    //                 )
    //             ),
    //             Material(
    //               //margin:const EdgeInsets.all(10),
    //                 child: Text('Force impulse: 0'
    //                 )
    //             ),
    //             Material(
    //               //margin:const EdgeInsets.all(10),
    //                 child: Text('Peak force: 0'
    //                 )
    //             ),
    //           ],
    //         ),
    //       ],
    //     ),*/
    //       floatingActionButton:Wrap(
    //         direction: Axis.horizontal,
    //         children: <Widget>[
    //           Container(
    //               margin:const EdgeInsets.all(10),
    //               child: ElevatedButton(
    //                 onPressed: bleController.isNotStarted ? bleController.sendKrille: null,
    //                 child: const Text('Krille'),
    //               )
    //           ),
    //           Container(
    //               margin:const EdgeInsets.all(10),
    //               child: ElevatedButton(
    //                 onPressed: bleController.isNotStarted ? bleController.initGo: null,
    //                 child: const Text('START'),
    //               )
    //           ),
    //         ],
    //       ),
    //     )
    // );
  }

}
