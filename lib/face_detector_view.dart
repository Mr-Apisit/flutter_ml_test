import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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

  List<XFile> faceRegList = [];

  CameraLensDirection _cameraLensDirection = CameraLensDirection.front;

  bool stressFace = false;
  bool closeEyeFace = false;

  bool upperFace = false;
  bool lowerFace = false;

  bool turnLeftFace = false;
  bool turnRightFace = false;

  bool winkLeftEye = false;
  bool winkRightEye = false;

  bool smileFace = false;
  bool bigSmileFace = false;

  @override
  void dispose() {
    _canProcess = false;
    stressFace = false;
    closeEyeFace = false;

    upperFace = false;
    lowerFace = false;

    turnLeftFace = false;
    turnRightFace = false;

    winkLeftEye = false;
    winkRightEye = false;

    smileFace = false;
    bigSmileFace = false;

    faceRegList = [];

    _faceDetector.close();
    super.dispose();
  }

  Image? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: image != null
          ? Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image,
              ),
            )
          : DetectorView(
              onImage: (inputImage) async {
                if (!_canProcess) return;
                if (_isBusy) return;
                _isBusy = true;
                final faces = await _faceDetector.processImage(inputImage);
                if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
                  for (final Face face in faces) {
                    var condition = face.boundingBox.center.direction;
                    if (condition > 1.1) {
                      print("face is to far away ...... :$condition");
                    } else if (condition < 1.05) {
                      print("face is to close ..... : $condition");
                    } else {
                      await Future.delayed(const Duration(milliseconds: 2000));
                      print("face is stand $condition");
                      await Future.delayed(const Duration(milliseconds: 2000));
                      print("save face");

                      if (face.smilingProbability! > 0.9) {
                        // print('BIG smile: ${face.smilingProbability}');
                        // final tempDir = await getTemporaryDirectory();
                        // File file = await File('${tempDir.path}/big_smile.jpg').create();
                        // file.writeAsBytesSync(inputImage.bytes!);
                        Uint8List imageBytes = Uint8List(0);
                        setState(() {
                          if (Platform.isIOS) {
                            imageBytes = _convertBgra8888ToJpeg(
                              inputImage.bytes!,
                              inputImage.metadata!.size.width.round(),
                              inputImage.metadata!.size.height.round(),
                            );
                          }
                          if (Platform.isAndroid) {
                            imageBytes = _convertNv21ToJpeg(
                              inputImage.bytes!,
                              inputImage.metadata!.size.width.round(),
                              inputImage.metadata!.size.height.round(),
                            );
                          }
                          image = Image.memory(imageBytes);
                        });
                        // print('file path ${file.path}');
                        // faceRegList.add(XFile(file.path));
                        _faceDetector.close();
                        break;
                        // print('length of map : ${faceRegList.length} and data : $faceRegList');
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
                    }
                  }
                  _isBusy = false;
                }
              },
              initialCameraLensDirection: _cameraLensDirection,
              onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
            ),
    );
  }

  Uint8List _convertNv21ToJpeg(Uint8List nv21Bytes, int width, int height) {
    final img.Image imgImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width + x;
        final int yp = nv21Bytes[index] & 0xFF;
        int r = yp;
        int g = yp;
        int b = yp;
        imgImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(imgImage));
  }

  Uint8List _convertBgra8888ToJpeg(Uint8List bgra8888Bytes, int width, int height) {
    final img.Image imgImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = y * width * 4 + x * 4;
        final int b = bgra8888Bytes[index];
        final int g = bgra8888Bytes[index + 1];
        final int r = bgra8888Bytes[index + 2];
        final int a = bgra8888Bytes[index + 3];
        imgImage.setPixelRgba(x, y, r, g, b, a);
      }
    }

    return Uint8List.fromList(img.encodeJpg(imgImage));
  }
}
