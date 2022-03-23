import 'dart:async';
import 'package:flutter/material.dart';
import 'package:startblock/view_model/data_view_view_model.dart';
import 'package:camera/camera.dart';
import '../helper/BLEController.dart';
import 'package:gallery_saver/gallery_saver.dart';

class RecordingScreen extends StatefulWidget {
  @override
  _RecordingState createState() => _RecordingState();
}

class _RecordingState extends State<RecordingScreen> {
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
    if(mounted){
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
                onPressed: !bleController.isNotStarted ? null: ()=>bleController.initGo(),
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
  }
}
