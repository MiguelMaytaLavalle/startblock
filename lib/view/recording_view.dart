import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../helper/BLEController.dart';
import 'package:gallery_saver/gallery_saver.dart';

/// This view is part of the bottomnavigationbar after selecting 'Connect' from the menu.
/// This view contains a controller for the back camera of a phone for recording an episode.
/// This view also contains a button 'Start' if a user only wants to record a episode without using the camera phone.

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
    //_initCamera();
  }

  void updateDetails(){
    if(mounted){
      setState((){});
    }
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(front, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      await GallerySaver.saveVideo(file.path);
    }
    else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  /// This method will be invoked if a user wants to return back to the menu view by pressing back
  /// It will invoke another method for disconnecting from the micro:bit and movesense if the user chooses to return
  /// back to the menu.
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
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ):Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
           /* CameraPreview(_cameraController),
            Padding(
              padding: const EdgeInsets.all(100),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecording ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(),
              ),
            ),*/
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
