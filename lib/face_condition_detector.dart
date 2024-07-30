import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'face_action_model.dart';
import 'jpeg_convertor.dart';

Future<FaceAction> faceActionDetector(
  Face face, {
  FaceActionType type = FaceActionType.faceStand,
  required InputImage inputImage,
}) async {
  var condition = face.boundingBox.center.direction;
  if (kDebugMode) {
    print("range : $condition Y.angle : ${face.headEulerAngleY}");
  }
  if (condition > 1.21) {
    return FaceAction("ใบหน้าไกลเกินไป");
  } else if (condition < 0.86) {
    return FaceAction("ใบหน้าใกล้เกินไป");
  } else {
    FaceAction faceAction = FaceAction("");
    switch (type) {
      case FaceActionType.faceStand:
        faceAction.msg = "มองตรง";
        if ((condition > 1.02 && condition < 1.1) && (face.headEulerAngleY! > 1.0 && face.headEulerAngleY! < 5.0)) {
          faceAction.faceStand = makeJpeg(inputImage);
          faceAction.msg = "บันทึกหน้าตรง .... ";
        }

      case FaceActionType.faceSmile:
        faceAction.msg = "ยิ้มมม";
        if (face.smilingProbability! > 0.7) {
          faceAction.faceSmile = makeJpeg(inputImage);
          faceAction.msg = "บันทึกหน้ายิ้ม .... ";
        }

      case FaceActionType.faceLeft:
        faceAction.msg = "หันซ้าย";
        if (face.headEulerAngleY! < -13.0) {
          faceAction.faceLeft = makeJpeg(inputImage);
          faceAction.msg = "บันทึกหันหัวซ้าย .... ";
        }

      case FaceActionType.faceRight:
        faceAction.msg = "หันขวา";
        if (face.headEulerAngleY! > 13.0) {
          faceAction.faceRight = makeJpeg(inputImage);
          faceAction.msg = "บันทึกหันหัวขวา .... ";
        }
    }
    return faceAction;

    // print('BIG smile: ${face.smilingProbability}');
    // final tempDir = await getTemporaryDirectory();
    // File file = await File('${tempDir.path}/big_smile.jpg').create();
    // file.writeAsBytesSync(inputImage.bytes!);

    // print('file path ${file.path}');
    // faceRegList.add(XFile(file.path));
    // print('length of map : ${faceRegList.length} and data : $faceRegList');

    // else if (face.smilingProbability! > 0.7) {
    //   print('jus Smile: ${face.smilingProbability}');
    // }
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

Uint8List makeJpeg(InputImage inputImage) {
  Uint8List imageBytes = Uint8List(0);
  if (Platform.isIOS) {
    imageBytes = convertBgra8888ToJpeg(
      inputImage.bytes!,
      inputImage.metadata!.size.width.round(),
      inputImage.metadata!.size.height.round(),
    );
  }
  if (Platform.isAndroid) {
    imageBytes = convertNv21ToJpeg(
      inputImage.bytes!,
      inputImage.metadata!.size.width.round(),
      inputImage.metadata!.size.height.round(),
    );
  }
  return imageBytes;
}
