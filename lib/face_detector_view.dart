
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detector_view.dart';
import 'face_action_model.dart';
import 'face_condition_detector.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({Key? key}) : super(key: key);

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
      // enableContours: true,
      // enableLandmarks: true,
    ),
  );

  bool _canProcess = true;
  bool _isBusy = false;

  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;
  FaceAction faceAction = FaceAction("เตรียมความพร้อม");
  List<Uint8List> filesImage = [];
  @override
  void dispose() {
    filesImage = [];
    _canProcess = false;

    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: filesImage.length == 4
          ? Center(
              child: SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final file in filesImage)
                      SizedBox(
                        width: 130,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(file),
                        ),
                      ),
                  ],
                ),
              ),
            )
          : DetectorView(
              onImage: (inputImage) async {
                if (!_canProcess) return;
                if (_isBusy) return;
                if (filesImage.length >= 4) return;
                _isBusy = true;
                final faces = await _faceDetector.processImage(inputImage);

                if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
                  FaceActionType type = FaceActionType.faceStand;
                  for (final face in faces) {
                    await Future.delayed(const Duration(milliseconds: 700));
                    if (filesImage.length == 1) type = FaceActionType.faceSmile;
                    if (filesImage.length == 2) type = FaceActionType.faceLeft;
                    if (filesImage.length == 3) type = FaceActionType.faceRight;
                    faceAction = await faceConditionDetectore(face, type: type, inputImage: inputImage);
                    if (faceAction.faceStand != null) {
                      filesImage.add(faceAction.faceStand!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(faceAction.msg)),
                          );
                      }
                      break;
                    } else if (faceAction.faceSmile != null) {
                      filesImage.add(faceAction.faceSmile!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(faceAction.msg)),
                          );
                      }
                      break;
                    } else if (faceAction.faceLeft != null) {
                      filesImage.add(faceAction.faceLeft!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(faceAction.msg)),
                          );
                      }
                      break;
                    } else if (faceAction.faceRight != null) {
                      filesImage.add(faceAction.faceRight!);
                      _faceDetector.close();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(content: Text(faceAction.msg)),
                          );
                      }
                      break;
                    }
                  }
                  _isBusy = false;
                  if (context.mounted) {
                    setState(() {});
                  }
                  if (kDebugMode) {
                    print("file length : ${filesImage.length}");
                  }
                }
              },
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
            ),
    );
  }
}
