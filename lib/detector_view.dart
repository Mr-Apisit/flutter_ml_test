import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'camera_view.dart';

class DetectorView extends StatelessWidget {
  final Function(InputImage inputImage) onImage;
  final Function()? onCameraFeedReady;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  const DetectorView({
    Key? key,
    required this.onImage,
    this.initialCameraLensDirection = CameraLensDirection.back,
    this.onCameraFeedReady,
    this.onCameraLensDirectionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CameraView(
      onImage: onImage,
      onCameraFeedReady: onCameraFeedReady,
      initialCameraLensDirection: initialCameraLensDirection,
      onCameraLensDirectionChanged: onCameraLensDirectionChanged,
    );
  }
}
