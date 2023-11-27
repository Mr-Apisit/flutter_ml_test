import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import 'detector_view.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({Key? key}) : super(key: key);

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.0,
      // enableContours: true,
      // enableLandmarks: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  bool _canProcess = true;
  bool _isBusy = false;

  var faceRegList = <String, File>{};

  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      onImage: (inputImage) async {
        if (!_canProcess) return;
        if (_isBusy) return;
        _isBusy = true;
        final faces = await _faceDetector.processImage(inputImage);
        if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
          for (final Face face in faces) {
            if (face.boundingBox.size.width < 600) {
              print("face is to far away");
            }
            if (face.boundingBox.size.width > 700) {
              print("face is to close");
            }
            if (face.smilingProbability! > 0.9) {
              print('BIG smile: ${face.smilingProbability}');
              final tempDir = await getTemporaryDirectory();
              File file = await File('${tempDir.path}/big_smile.jpg').create();
              file.writeAsBytesSync(inputImage.bytes!);
              Image.memory(inputImage.bytes!);
              print('file path ${file.path}');
              faceRegList.addAll({"smile": file});
              print('length of map : ${faceRegList.length} and data : $faceRegList');
            } else if (face.smilingProbability! > 0.7) {
              print('jus Smile: ${face.smilingProbability}');
            }
            // if (face.headEulerAngleZ! < -13.0) {
            //   print('rotate head RIGHT : ${face.headEulerAngleZ}');
            // }
            // if (face.headEulerAngleZ! > 13.0) {
            //   print('rotate head LEFT : ${face.headEulerAngleZ}');
            // }
            // if (face.headEulerAngleX! < -13.0) {
            //   print('down head : ${face.headEulerAngleX}');
            // }
            // if (face.headEulerAngleX! > 13.0) {
            //   print('up head : ${face.headEulerAngleX}');
            // }
            // if (face.headEulerAngleY! < -13.0) {
            //   print('turn left head : ${face.headEulerAngleY}');
            // }
            // if (face.headEulerAngleY! > 13.0) {
            //   print('turn right head : ${face.headEulerAngleY}');
            // }
            // if (face.leftEyeOpenProbability! < 0.07) {
            //   print('Wik left eye: ${face.leftEyeOpenProbability}');
            // }
            // if (face.rightEyeOpenProbability! < 0.07) {
            //   print('Wik right eye: ${face.rightEyeOpenProbability}');
            // }
          }
          _isBusy = false;
          if (mounted) {
            setState(() {});
          }
        }
      },
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }
}
