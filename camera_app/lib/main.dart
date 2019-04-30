import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:typed_data';
import 'package:modal_progress_hud/modal_progress_hud.dart';

List<CameraDescription> cameras;

main() async {
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() {
    return AppState();
  }
}

class AppState extends State<MyApp> {
  CameraController _cameraController;
  bool _processing = false;

  _setProcessing(bool processing) {
    setState(() {
      this._processing = processing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Camera'),
          ),
          body: ModalProgressHUD(
            inAsyncCall: _processing,
            child: Camera(
              cameraController: this._cameraController,
              setProcessing: this._setProcessing,
            ),
          )),
    );
  }

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cameras[0], ResolutionPreset.low);
    final imageLabeler = FirebaseVision.instance.imageLabeler();
    _cameraController.initialize().then((_) {
      setState(() {});
      _cameraController.startImageStream((image) {
        if (!this._processing) return;
        final List<int> bytes = [];
        for (final plane in image.planes) {
          bytes.addAll(plane.bytes);
        }
        final metaData = FirebaseVisionImageMetadata(
            size: Size(image.width + 0.0, image.height + 0.0),
            rawFormat: null,
            planeData: []);
        final fvimage =
        FirebaseVisionImage.fromBytes(Uint8List.fromList(bytes), metaData);
        imageLabeler.processImage(fvimage).then((labels) {
          for (final label in labels) {
            print(label.text);
          }
        });
        setState(() {
          this._processing = false;
        });
      });
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

class Camera extends StatelessWidget {
  final CameraController cameraController;
  final void Function(bool processing) setProcessing;

  Camera({@required this.cameraController, @required this.setProcessing});

  onPressed() {
    this.setProcessing(true);
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return Container(
        decoration: BoxDecoration(color: Colors.black),
        child: Stack(children: <Widget>[
          Align(
              alignment: Alignment.center,
              child: AspectRatio(
                aspectRatio: cameraController.value.aspectRatio,
                child: CameraPreview(cameraController),
              )),
          Align(
            alignment: Alignment(0.0, 0.75),
            child: RaisedButton(
              onPressed: this.onPressed,
              child: Text('Take'),
            ),
          ),
        ]));
  }
}
