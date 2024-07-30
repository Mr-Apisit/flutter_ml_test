import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'detector_view.dart';
import 'face_action_model.dart';
import 'face_condition_detector.dart';
import 'send_to_server.dart';

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
  List<Uint8List> filesImage = [];
  ValueNotifier<String> valueNotifier = ValueNotifier("จัดใบหน้าอยู่ตรงกลาง");
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: DetectorView(
              onImage: (inputImage) async {
                if (!_canProcess) return;
                if (_isBusy) return;
                if (filesImage.length >= 4) return;
                _isBusy = true;
                final faces = await _faceDetector.processImage(inputImage);
                if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
                  FaceAction faceAction = FaceAction("");
                  FaceActionType type = FaceActionType.faceStand;
                  for (final face in faces) {
                    await Future.delayed(const Duration(milliseconds: 700));

                    if (filesImage.length == 1) type = FaceActionType.faceSmile;

                    if (filesImage.length == 2) type = FaceActionType.faceLeft;

                    if (filesImage.length == 3) type = FaceActionType.faceRight;

                    faceAction = await faceActionDetector(face, type: type, inputImage: inputImage);
                    valueNotifier.value = faceAction.msg;
                    if (faceAction.faceStand != null) {
                      filesImage.add(faceAction.faceStand!);
                      break;
                    } else if (faceAction.faceSmile != null) {
                      filesImage.add(faceAction.faceSmile!);

                      break;
                    } else if (faceAction.faceLeft != null) {
                      filesImage.add(faceAction.faceLeft!);

                      break;
                    } else if (faceAction.faceRight != null) {
                      filesImage.add(faceAction.faceRight!);
                      _faceDetector.close();

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
                  if (filesImage.length == 4) {
                    await sendToServer(filesImage).then((_) => Navigator.pop(context));
                  }
                }
              },
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
            ),
          ),
          Positioned(
              top: 80,
              width: MediaQuery.sizeOf(context).width / 1.5,
              child: ValueListenableBuilder(
                  valueListenable: valueNotifier,
                  builder: (context, value, _) {
                    return Text(
                      value,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Colors.white,
                        shadows: [
                          const BoxShadow(
                            blurRadius: 3,
                            spreadRadius: 1,
                          )
                        ],
                      ),
                    );
                  }))
        ],
      ),
    );
  }
}
